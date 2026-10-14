extends SceneTree
# Normalize generated cutouts only; original drawings and their alpha are retained.
const SOURCE = "res://docs/base_camp/dusk/sources/"
const OUTPUT = "res://assets/base_camp/dusk/"
const BUILDINGS = ["market", "forge", "church", "expeditions", "refuge", "projects", "training", "plot"]
# The generated sheet has irregular spacing; bounds follow each actual silhouette.
const REGIONS = [Rect2i(15,12,431,436), Rect2i(467,51,432,400), Rect2i(914,12,399,448), Rect2i(1312,107,450,355), Rect2i(13,476,460,371), Rect2i(473,472,493,366), Rect2i(1008,501,226,344), Rect2i(1275,571,496,271)]
func _initialize() -> void:
	var source = Image.load_from_file(SOURCE + "buildings.png")
	if source == null:
		push_error("Missing dusk building atlas")
		quit(1)
		return
	for i in range(BUILDINGS.size()):
		var cell = source.get_region(REGIONS[i])
		var used = cell.get_used_rect()
		cell = cell.get_region(used)
		var factor = minf(480.0 / cell.get_width(), 480.0 / cell.get_height())
		cell.resize(roundi(cell.get_width() * factor), roundi(cell.get_height() * factor), Image.INTERPOLATE_LANCZOS)
		var output = Image.create(512, 512, false, Image.FORMAT_RGBA8) if BUILDINGS[i] == "training" else Image.create(cell.get_width()+32, cell.get_height()+32, false, Image.FORMAT_RGBA8)
		output.fill(Color.TRANSPARENT)
		output.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i((output.get_width()-cell.get_width())/2, output.get_height()-16-cell.get_height()))
		output.save_png(OUTPUT + BUILDINGS[i] + ".png")
	if FileAccess.file_exists(SOURCE + "fire.png"):
		pack_fire()
	quit()
func pack_fire() -> void:
	var source = Image.load_from_file(SOURCE + "fire.png")
	source.resize(1536, 1024, Image.INTERPOLATE_LANCZOS)
	source.save_png(OUTPUT + "fire.png")
	var baselines = []
	for i in range(24):
		var bottom = 0
		for y in range(256):
			for x in range(256):
				if source.get_pixel((i % 6)*256+x, (i / 6)*256+y).a >= 0.5:
					bottom = y + 1
		baselines.append(bottom)
	FileAccess.open("res://data/camp_fire_dusk.json",FileAccess.WRITE).store_string(JSON.stringify({"baselines":baselines},"\t"))
