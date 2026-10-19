// @exec: {"yield_time_ms": 1000, "max_output_tokens": 800}
const root="/var/www/html/EternoRetorno";
const quote=s=>"'"+s.replaceAll("'","'\\''")+"'";
let total=0;
for(let wave=0;wave<12;wave++){
 const read=await tools.exec_command({cmd:"python3 scripts/postapocalyptic_art_queue.py pending 16",max_output_tokens:50000});
 const state=JSON.parse(read.output);
 if(!state.jobs.length){text({production_complete:state.pending===0,generated_this_run:total,pending:state.pending});break;}
 let next=0;let failure=null;
 async function worker(){
  while(next<state.jobs.length && !failure){
   const job=state.jobs[next++];
   try{
    let refs=[root+"/art_sources/art_direction/postapocalyptic/sources/identity_"+(job.hero||"warrior")+".png"];
    if(job.kind==="card_bank")refs=[root+"/assets/forge/icons/warrior_1.png",root+"/assets/forge/icons/mage_1.png"];
    else if(job.kind==="interior" || (!job.hero && ["scene","cinematic","map","contract","objects_atlas","chest_atlas","numbers","fire"].includes(job.kind)))refs=[root+"/assets/base_camp/dusk/background.png"];
    if(job.reference_bank)refs.push(root+"/"+job.reference_bank);
    const result=await tools.image_gen__imagegen({prompt:job.prompt,referenced_image_paths:refs,transparent_background:job.transparent});
    const original=(result.output_hint||"").match(/\/home\/fede\/\.codex\/generated_images\/[^\s]+\/exec-[^\s]+\.png/)?.[0];
    if(!original)throw new Error("No saved image: "+job.id);
    const record={...job,original,references:refs,tool:"image_gen.imagegen"};
    const saved=await tools.exec_command({cmd:"python3 scripts/postapocalyptic_art_queue.py store "+quote(JSON.stringify(record)),max_output_tokens:500});
    if(saved.exit_code!==0)throw new Error(saved.output);
    total++;notify({generated:job.id,generated_this_run:total});
   }catch(error){failure={job:job.id,error:String(error)};}
  }
 }
 await Promise.allSettled(Array.from({length:4},()=>worker()));
 if(failure){text({stopped:true,failure,generated_this_run:total});break;}
 await yield_control();
}
