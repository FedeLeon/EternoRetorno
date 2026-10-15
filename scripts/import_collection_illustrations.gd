extends SceneTree
## Resize authored comic illustrations; never generates or substitutes artwork.
const BASE = "res://docs/collection/comic_illustrations/"
const INVENTORY = "res://docs/art_direction/postapocalyptic/"

func _initialize() -> void:
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string(BASE + "jobs.json"))
	if jobs.size() != 28:
		push_error("Expected 28 achievement illustrations")
		quit(1)
		return
	jobs.append(JSON.parse_string(FileAccess.get_file_as_string(BASE + "secret.json")))
	# Validate the entire source set before replacing any active asset.
	var images: Dictionary = {}
	for job in jobs:
		var image = Image.new()
		var path = "res://" + job.source
		if not FileAccess.file_exists(path) or image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK:
			push_error("Missing comic source: " + job.id)
			quit(1)
			return
		if image.get_width() != image.get_height():
			push_error("Achievement source must be square: " + job.id)
			quit(1)
			return
		images[job.id] = image
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(INVENTORY + "assets.json"))
	manifest.erase("assets/collection/secret.svg")
	for job in jobs:
		var image: Image = images[job.id]
		image.resize(512, 512, Image.INTERPOLATE_LANCZOS)
		preload("res://scripts/sketchbook_sheet_packer.gd").save(image, "res://" + job.target)
		manifest[job.target] = {"sha256": FileAccess.get_sha256("res://" + job.target), "source": job.source, "source_sha256": FileAccess.get_sha256("res://" + job.source), "style": "postapocalyptic_comic", "tool": "image_gen.imagegen", "processing": "proportional Lanczos resize to 512 square", "generation": "docs/collection/comic_illustrations/%s.json" % job.id, "inputs_sha256": {job.reference: FileAccess.get_sha256("res://" + job.reference)}}
	FileAccess.open(INVENTORY + "assets.json", FileAccess.WRITE).store_string(JSON.stringify(manifest, "\t", false) + "\n")
	# Native-vector rebuilds must never overwrite these generated illustrations.
	var vectors: Array = JSON.parse_string(FileAccess.get_file_as_string(INVENTORY + "vectors.json"))
	vectors = vectors.filter(func(record): return not record.target.begins_with("assets/collection/icons/"))
	FileAccess.open(INVENTORY + "vectors.json", FileAccess.WRITE).store_string(JSON.stringify(vectors, "  ", false) + "\n")
	var queue: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(INVENTORY + "queue.json"))
	var by_target: Dictionary = {}
	for job in jobs: by_target[job.target] = job
	for entry in queue.derived:
		if entry.target.begins_with("assets/collection/icons/"):
			var job: Dictionary = by_target[entry.target]
			entry.kind = "collection_illustration"
			entry.dimensions = [512, 512]
			entry.transparent = false
			entry.source = job.source
			entry.prompt = job.prompt
	FileAccess.open(INVENTORY + "queue.json", FileAccess.WRITE).store_string(JSON.stringify(queue, "  ", false) + "\n")
	print("COMIC ACHIEVEMENT ILLUSTRATIONS: ", jobs.size())
	quit()
