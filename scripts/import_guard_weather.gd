extends SceneTree
## Geometric packing of authored drawings; preserves colors, proportions and IDs.
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
func _initialize() -> void:
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/guard_weather_2026_10_16/jobs.json"))
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/art_direction/postapocalyptic/assets.json"))
	for job in jobs:
		if job.kind == "guard": continue # Battle guard animation retired.
		if manifest.get(job.target,{}).get("comic_rebuild_revision",0)==1: continue
		var image: Image
		image = Image.load_from_file("res://" + job.source)
		if image == null: push_error("Missing scenery: " + job.id); quit(1); return
		image.resize(1536,1024,Image.INTERPOLATE_LANCZOS)
		DirAccess.make_dir_recursive_absolute("res://" + job.target.get_base_dir())
		Pack.save(image, "res://" + job.target)
		manifest[job.target] = {"sha256":FileAccess.get_sha256("res://" + job.target),"source":job.source,"source_sha256":FileAccess.get_sha256("res://" + job.source),"style":"postapocalyptic_comic","guard_weather_revision":1,"processing":"new low-key comic scenery, proportional 1536x1024 fit"}
		print("GUARD/WEATHER: ", job.target)
	FileAccess.open("res://art_sources/art_direction/postapocalyptic/assets.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	quit()
