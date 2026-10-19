// Execute with the integrated ImageGen tools, never an API-key fallback.
const quote=s=>"'"+s.replaceAll("'","'\\''")+"'";
let done=0;
for(let batch=0;batch<200;batch++){
 const read=await tools.exec_command({cmd:"python3 scripts/comic_rebuild_queue.py remaining 2",max_output_tokens:30000});
 const state=JSON.parse(read.output);
 if(!state.jobs.length){text({complete:true,done});break;}
 let batchDone=0;
 const results=await Promise.allSettled(state.jobs.map(async job=>{
  const refs=job.references||(job.hero?["/var/www/html/EternoRetorno/art_sources/comic_rebuild_2026_10_17/sources/reference_"+job.hero+".png"]:[]);
  const result=await tools.image_gen__imagegen({prompt:job.prompt,...(refs.length?{referenced_image_paths:refs}:{}),transparent_background:job.transparent});
  const original=result.output_hint?.match(/as (\/\S+\.png) by default/)?.[1];
  if(!original)throw Error("No saved image "+job.id);
  const record={...job,original_source:original,references:refs,tool:"image_gen.imagegen",status:"generated"};
  const saved=await tools.exec_command({cmd:"cp "+quote(original)+" "+quote(job.source)+"\ncat > "+quote("art_sources/comic_rebuild_2026_10_17/jobs/"+job.id+".json")+" <<'COMIC_JOB'\n"+JSON.stringify(record,null,2)+"\nCOMIC_JOB",max_output_tokens:100});
  if(saved.exit_code!==0)throw Error(saved.output);
  done++;batchDone++;notify({generated:job.id,remaining_group_done:done,pending:state.pending-batchDone});
 }));
 const failed=results.filter(r=>r.status==="rejected");
 if(failed.length){text({failed:failed.map(f=>String(f.reason)),done});break;}
}
