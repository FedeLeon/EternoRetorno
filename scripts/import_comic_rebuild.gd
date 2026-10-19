extends SceneTree
## Integrates completed generated art, preserving resource paths and save IDs.
const Root="res://art_sources/comic_rebuild_2026_10_17/"
const Pack=preload("res://scripts/sketchbook_sheet_packer.gd")
const Rebuild=preload("res://scripts/comic_rebuild_packer.gd")
const Retired=preload("res://scripts/resource_retirements.gd")
func _initialize() -> void:
	var queue:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(Root+"queue.json"))
	var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/art_direction/postapocalyptic/assets.json"))
	var installed=0
	for planned in queue.jobs:
		var record_path=Root+"jobs/"+planned.id+".json"
		if not FileAccess.file_exists(record_path):continue
		var job:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(record_path))
		if job.targets.all(func(t):return Retired.contains(t.path)):continue
		if job.kind in ["hero_sheet","machine_bank","enemy_sheet"]: continue # Retired battle atlas jobs.
		if job.targets.all(func(t):return manifest.get(t.path,{}).has("user_preserved_revision")):continue
		var revision=5 if job.kind=="numbers" else 4 if job.id=="title__background" or job.kind in ["card_bank","animal_sheet"] else 3
		var signature=FileAccess.get_sha256("res://"+job.source)
		if job.targets.all(func(t):return manifest.get(t.path,{}).get("comic_rebuild_revision",0)==1 and manifest[t.path].source_sha256==signature and manifest[t.path].get("comic_processing_version",0)==revision):continue
		var images=Rebuild.process(job)
		if images.size()!=job.targets.size():push_error("Invalid generated layout: "+job.id);quit(1);return
		for target in job.targets:
			var image:Image=images.get(target.path)
			if image==null or image.get_size()!=Vector2i(target.dimensions[0],target.dimensions[1]):
				push_error("Generated size mismatch: "+target.path);quit(1);return
		for path in images:
			if Retired.contains(path):continue
			if images[path]==null:push_error("Empty generated image: "+path);quit(1);return
			DirAccess.make_dir_recursive_absolute(("res://"+path).get_base_dir())
			Pack.save(images[path],"res://"+path)
			manifest[path]={"source":job.source,"source_sha256":signature,"sha256":FileAccess.get_sha256("res://"+path),"job":job.id,"style":"postapocalyptic_comic","comic_rebuild_revision":1,"comic_processing_version":revision,"processing":"new authored comic illustration, geometric crop/pack, same resource path"}
			installed+=1
		if job.kind=="fire_bank":
			FileAccess.open("res://data/camp_fire_dusk.json",FileAccess.WRITE).store_string(JSON.stringify({"baselines":[248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248,248]},"\t")+"\n")
		print("COMIC REBUILD: ",job.id," / ",images.size())
	FileAccess.open("res://art_sources/art_direction/postapocalyptic/assets.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	print("COMIC REBUILD INTEGRATED: ",installed)
	quit()
