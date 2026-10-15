// @exec: {"yield_time_ms": 1000, "max_output_tokens": 600}
const root="/var/www/html/EternoRetorno";
const quote=s=>"'"+s.replaceAll("'","'\\''")+"'";
let done=0;
for(let batch=0;batch<(typeof generationBatches === "number" ? generationBatches : 1);batch++){
 const read=await tools.exec_command({cmd:"python3 scripts/postapocalyptic_art_queue.py pending 4",max_output_tokens:22000});
 const state=JSON.parse(read.output);
 if(!state.jobs.length){text({complete:true,done,state});break;}
 const results=await Promise.allSettled(state.jobs.map(async job=>{
  const hero=job.hero || "warrior";
  const refs=[root+"/docs/art_direction/postapocalyptic/sources/identity_"+hero+".png"];
  if(job.reference_bank)refs.push(root+"/"+job.reference_bank);
  const result=await tools.image_gen__imagegen({prompt:job.prompt,referenced_image_paths:refs,transparent_background:job.transparent});
  const original=(result.output_hint||"").match(/\/home\/fede\/\.codex\/generated_images\/[^\s]+\/exec-[^\s]+\.png/)?.[0];
  if(!original)throw new Error("No saved image: "+job.id);
  const record={...job,original,references:refs,tool:"image_gen.imagegen"};
  const saved=await tools.exec_command({cmd:"python3 scripts/postapocalyptic_art_queue.py store "+quote(JSON.stringify(record)),max_output_tokens:500});
  if(saved.exit_code!==0)throw new Error(saved.output);
  done++;notify({generated:job.id,done,pending:state.pending-done%4});
  return job.id;
 }));
 const failed=results.filter(r=>r.status==="rejected");
 if(failed.length){text({stopped:true,failed:failed.map(f=>String(f.reason)),done});break;}
 await yield_control();
}

