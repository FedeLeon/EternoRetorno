extends SceneTree
## Geometric packing of authored drawings; preserves colors, proportions and IDs.
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
func _initialize() -> void:
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string("res://docs/guard_weather_2026_10_16/jobs.json"))
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/art_direction/postapocalyptic/assets.json"))
	var metrics: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/detailed_heroes.json"))
	for job in jobs:
		if manifest.get(job.target,{}).get("comic_rebuild_revision",0)==1: continue
		var image: Image
		if job.kind == "guard":
			var poses = Pack.actor_cells("res://" + job.source, 6, 4)
			if poses.size() != 24: push_error("Expected 24 guard drawings: " + job.hero); quit(1); return
			var extent = Vector2.ZERO
			for pose in poses: extent = extent.max(Vector2(pose.get_size()))
			var ratio = minf(float(job.body_height) / poses[0].get_height(), minf(228.0 / extent.x, 228.0 / extent.y))
			image = Image.create(1536, 1024, false, Image.FORMAT_RGBA8)
			image.fill(Color.TRANSPARENT)
			for i in range(24):
				var pose: Image = poses[i].duplicate()
				pose.convert(Image.FORMAT_RGBA8)
				pose.resize(maxi(1,roundi(pose.get_width()*ratio)),maxi(1,roundi(pose.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
				var bottom = Pack.bottom(pose)
				# Anchor the feet, not a changing weapon/hair bounding-box center.
				var band = Rect2i(0, maxi(0,bottom-20), pose.get_width(), mini(20,bottom))
				var feet = Pack.bounds(pose.get_region(band), 0.5)
				var center = feet.position.x + feet.size.x / 2
				image.blit_rect(pose, Rect2i(Vector2i.ZERO,pose.get_size()), Vector2i((i%6)*256+128-center,(i/6)*256+240-bottom))
			metrics[job.hero].idle_height = Pack.bounds(image.get_region(Rect2i(0,0,256,256)),0.5).size.y * 0.5
			metrics[job.hero].guard_frames = 24
		else:
			image = Image.load_from_file("res://" + job.source)
			if image == null: push_error("Missing scenery: " + job.id); quit(1); return
			image.resize(1536, 1024, Image.INTERPOLATE_LANCZOS)
		DirAccess.make_dir_recursive_absolute("res://" + job.target.get_base_dir())
		Pack.save(image, "res://" + job.target)
		manifest[job.target] = {"sha256":FileAccess.get_sha256("res://" + job.target),"source":job.source,"source_sha256":FileAccess.get_sha256("res://" + job.source),"style":"postapocalyptic_comic","guard_weather_revision":1,"processing":"24 authored guard drawings, common scale and foot anchor" if job.kind=="guard" else "new low-key comic scenery, proportional 1536x1024 fit"}
		print("GUARD/WEATHER: ", job.target)
	FileAccess.open("res://data/detailed_heroes.json",FileAccess.WRITE).store_string(JSON.stringify(metrics,"\t")+"\n")
	FileAccess.open("res://docs/art_direction/postapocalyptic/assets.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	quit()
