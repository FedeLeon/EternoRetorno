extends SceneTree
## Geometry/import only: generated illustrations never affect card rules or saves.
const DIRECTORY = "res://docs/cards/minimal/"
const RUNTIME = "res://data/card_art.json"
func _initialize() -> void:
	var queue: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DIRECTORY+"queue.json"))
	for job in queue.jobs:
		if not FileAccess.file_exists("res://"+job.source):
			push_error("Missing illustration: "+job.card_id)
			quit(1)
			return
	if not FileAccess.file_exists(DIRECTORY+"previous_mapping.json"):
		DirAccess.copy_absolute(RUNTIME,DIRECTORY+"previous_mapping.json")
	var mapping = {}
	var manifest = {}
	for job in queue.jobs:
		var source = "res://"+job.source
		var image = Image.load_from_file(source)
		if image == null or image.get_width() < 1000 or image.get_height() < 600:
			push_error("Invalid source: "+job.card_id)
			quit(1)
			return
		# Crop only empty margins to the shared card slot; never distort a motif.
		var crop = image.get_size()
		if float(crop.x)/crop.y > 16.0/9.0: crop.x = roundi(crop.y*16.0/9.0)
		else: crop.y = roundi(crop.x*9.0/16.0)
		var rect = Rect2i((image.get_size()-crop)/2,crop)
		var output = image.get_region(rect)
		output.resize(512,288,Image.INTERPOLATE_LANCZOS)
		var target = "res://"+job.target
		DirAccess.make_dir_recursive_absolute(target.get_base_dir())
		if output.save_png(target) != OK:
			push_error("Cannot save: "+target)
			quit(1)
			return
		mapping[job.card_id] = {"source":target}
		var ledger = "res://docs/art_direction/migration/jobs/"+job.id+".json"
		var provenance: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ledger))
		provenance.sha256 = FileAccess.get_sha256(target)
		provenance.source_sha256 = FileAccess.get_sha256(source)
		provenance.dimensions = [512,288]
		provenance.crop = [rect.position.x,rect.position.y,rect.size.x,rect.size.y]
		provenance.status = "integrated"
		manifest[job.target] = provenance
		write_json(source.get_basename()+".json",provenance)
	write_json(DIRECTORY+"assets.json",manifest)
	# Publish the complete mapping only after all eighty-eight outputs are ready.
	write_json(RUNTIME+".pending",mapping)
	if DirAccess.rename_absolute(RUNTIME+".pending",RUNTIME) != OK:
		push_error("Cannot publish complete card art mapping")
		quit(1)
		return
	print("MINIMAL CARDS: ",mapping.size()," illustrations installed at 512x288")
	quit()
func write_json(path: String, value: Dictionary) -> void:
	FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(value,"\t")+"\n")
