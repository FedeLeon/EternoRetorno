extends SceneTree
## Preflight the complete requested set; process authored images only.
const BASE = "res://docs/cards/pixel_retain/"
const INVENTORY = "res://docs/art_direction/postapocalyptic/"
func _initialize() -> void:
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string(BASE + "jobs.json"))
	if jobs.size() != 96:
		push_error("Expected the complete 96-asset card plan")
		quit(1)
		return
	if "--frames-only" in OS.get_cmdline_user_args(): jobs = jobs.filter(func(job): return job.kind != "illustration")
	var images: Dictionary = {}
	for job in jobs:
		var img = Image.new()
		if img.load_png_from_buffer(FileAccess.get_file_as_bytes("res://" + job.source)) != OK:
			push_error("Missing pixel card source: " + job.id)
			quit(1)
			return
		images[job.id] = img
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(INVENTORY + "assets.json"))
	var targets: Dictionary = {}
	for job in jobs:
		var img: Image = images[job.id]
		img.resize(512, 340 if job.kind == "illustration" else 768, Image.INTERPOLATE_LANCZOS)
		preload("res://scripts/sketchbook_sheet_packer.gd").save(img, "res://" + job.target)
		targets[job.target] = job
		manifest[job.target] = {"sha256": FileAccess.get_sha256("res://" + job.target), "source": job.source, "source_sha256": FileAccess.get_sha256("res://" + job.source), "style": "postapocalyptic_pixel_cards", "tool": "image_gen.imagegen", "processing": "Lanczos resize; text and values remain runtime UI", "generation": "docs/cards/pixel_retain/%s.json" % job.id}
		var ledger: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASE + job.id + ".json"))
		var reference: String = str(ledger.get("reference", ""))
		if FileAccess.file_exists("res://" + reference):
			manifest[job.target].inputs_sha256 = {reference: FileAccess.get_sha256("res://" + reference)}
	FileAccess.open(INVENTORY + "assets.json", FileAccess.WRITE).store_string(JSON.stringify(manifest, "\t", false) + "\n")
	var vectors: Array = JSON.parse_string(FileAccess.get_file_as_string(INVENTORY + "vectors.json"))
	vectors = vectors.filter(func(record): return not targets.has(record.target))
	FileAccess.open(INVENTORY + "vectors.json", FileAccess.WRITE).store_string(JSON.stringify(vectors, "  ", false) + "\n")
	var queue: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(INVENTORY + "queue.json"))
	for entry in queue.derived:
		if targets.has(entry.target):
			var job: Dictionary = targets[entry.target]
			entry.kind = "pixel_card_" + job.kind
			entry.source = job.source
			entry.prompt = job.prompt
			entry.dimensions = [512, 340 if job.kind == "illustration" else 768]
	FileAccess.open(INVENTORY + "queue.json", FileAccess.WRITE).store_string(JSON.stringify(queue, "  ", false) + "\n")
	print("PIXEL CARD ASSETS: ", jobs.size())
	quit()
