// Measures a user-provided existing Web export. Never exports or writes TestWeb.
const { chromium } = require('playwright');
const fs = require('node:fs');
const path = require('node:path');
const url = process.env.WEB_PERF_URL || 'http://127.0.0.1:8766';
const output = process.env.WEB_PERF_OUTPUT || 'artifacts/polish/web-performance.json';
const percentile = (values, fraction) => [...values].sort((a,b)=>a-b)[Math.min(values.length-1, Math.floor(values.length*fraction))];
let browser;
(async () => {
 browser = await chromium.launch({args:['--enable-unsafe-swiftshader']});
 const page = await browser.newPage({viewport:{width:1280,height:720}});
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.addInitScript(()=> {
  window.__frames=[];let last;
  const tick=now=>{if(last) window.__frames.push(now-last);last=now;requestAnimationFrame(tick);};requestAnimationFrame(tick);
 });
 const started=Date.now();await page.goto(url);
 await page.waitForFunction(()=>!document.getElementById('status'),null,{timeout:90000});
 const loadMilliseconds=Date.now()-started;
 await page.waitForTimeout(1000);await page.mouse.click(635,566);await page.waitForTimeout(1000);
 const scenarios=[];
 for(const [name,click] of [['camp',null],['adventures-menu',[1090,267]],['hero-selection',[640,437]]]) {
  if(click) {await page.mouse.click(...click);await page.waitForTimeout(800);}
  await page.evaluate(()=>window.__frames=[]);await page.waitForTimeout(3500);
  const state=await page.evaluate(()=>({frames:window.__frames,memory:performance.memory?{usedJSHeapSize:performance.memory.usedJSHeapSize,totalJSHeapSize:performance.memory.totalJSHeapSize}:null}));
  scenarios.push({name,p50_ms:percentile(state.frames,.5),p95_ms:percentile(state.frames,.95),p99_ms:percentile(state.frames,.99),frames:state.frames.length,memory:state.memory});
  await page.screenshot({path:path.join(path.dirname(output),'web-'+name+'.png')});
 }
 const resources=await page.evaluate(()=>performance.getEntriesByType('resource').map(r=>({name:r.name.split('/').pop(),duration_ms:r.duration,bytes:r.encodedBodySize})));
 const report={url,measured_at:new Date().toISOString(),load_ms:loadMilliseconds,scenarios,resources,errors,build:process.env.WEB_PERF_BUILD || 'Existing export; verify its date before attributing results to current source',browser:await browser.version()};
 fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');
 await page.screenshot({path:path.join(path.dirname(output),'web-performance.png')});await browser.close();
 console.log(JSON.stringify(report));process.exitCode=errors.length?1:0;
})().catch(async e=>{console.error(e);await browser?.close();process.exitCode=1;});
