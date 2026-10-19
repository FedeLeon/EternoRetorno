// Probe an existing export; never creates or overwrites export files.
// Requires Playwright and an HTTP server. See docs/AUDIO.md.
const { chromium } = require('playwright');
const fs = require('node:fs');
const assert = require('node:assert/strict');

async function probe(browser, appendByCount) {
  const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.addInitScript(() => {
    window.audioContexts = [];
    const Original = window.AudioContext;
    window.AudioContext = class extends Original {
      constructor(...args) {
        super(...args);
        window.audioContexts.push(this);
        this.meter = this.createAnalyser();
        this.meter.fftSize = 2048;
        this.meter.connect(this.destination);
        const originalConnect = AudioNode.prototype.connect;
        const destination = this.destination;
        const meter = this.meter;
        AudioNode.prototype.connect = function (target, ...rest) {
          return originalConnect.call(this, target === destination ? meter : target, ...rest);
        };
      }
    };
  });
  await page.route('**/index.js', async route => {
    const response = await route.fetch();
    let body = await response.text();
    assert(body.includes('var GodotAudio={'), 'Godot 4.7.2 audio graph available');
    body = body.replace('var GodotAudio={', 'var GodotAudio=window.__godotAudio={');
    if (appendByCount) {
      // Same browser operation as AudioServer.set_bus_count(current + 1).
      assert(body.includes('static addAt(index){const newBus'));
      body = body.replace('static addAt(index){const newBus',
        'static addAt(index){if(index===-1){GodotAudio.Bus.setCount(GodotAudio.buses.length+1);return;}const newBus');
    }
    await route.fulfill({ response, body });
  });
  await page.goto(process.env.WEB_AUDIO_URL || 'http://127.0.0.1:8766');
  await page.waitForFunction(() => window.__godotAudio?.buses?.length >= 4, null, { timeout: 60000 });
  await page.waitForTimeout(3000);
  await page.mouse.click(630, 650);
  await page.waitForTimeout(1500);
  const result = await page.evaluate(() => ({
    buses: window.__godotAudio.buses.map(bus => ({ id: bus.getId(), send: bus.getSend()?.getId() ?? null })),
    contexts: window.audioContexts.map(context => {
      const samples = new Float32Array(context.meter.fftSize);
      context.meter.getFloatTimeDomainData(samples);
      return { state: context.state, peak: Math.max(...samples.map(Math.abs)) };
    })
  }));
  result.errors = errors;
  await page.close();
  return result;
}

(async () => {
  const browser = await chromium.launch({ headless: true,
    args: ['--enable-unsafe-swiftshader', '--autoplay-policy=user-gesture-required'] });
  try {
    const original = await probe(browser, false);
    const repaired = await probe(browser, true);
    assert.equal(repaired.errors.length, 0);
    assert.equal(repaired.buses[0].send, null, 'Master connects to browser output');
    assert(repaired.buses.slice(1).every(bus => bus.send === 0), 'other channels connect to Master');
    assert(repaired.contexts.some(context => context.state === 'running' && context.peak > 0.0001), 'real nonzero browser mix');
    const result = { original, repaired };
    fs.mkdirSync('artifacts/audio', { recursive: true });
    fs.writeFileSync('artifacts/audio/web_bus_probe.json', JSON.stringify(result, null, 2));
    console.log(JSON.stringify(result, null, 2));
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
