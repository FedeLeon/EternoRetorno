extends SceneTree
## Repack existing frames without edits, as four-pose references for imagegen.
func _initialize() -> void:
	var jobs = JSON.parse_string(FileAccess.get_file_as_string("res://docs/comic/hd/prompts.json"))
	DirAccess.make_dir_recursive_absolute("res://docs/comic/hd/references")
	for job in jobs:
		var source = Image.load_from_file("res://docs/comic/smooth/sources/" + job.sequence + ".png")
		var cell = Vector2i(source.get_width() / 4, source.get_height() / 4)
		var target = Image.create(cell.x * 2, cell.y * 2, false, Image.FORMAT_RGBA8)
		for i in range(4):
			target.blit_rect(source, Rect2i(Vector2i(i, job.part) * cell, cell), Vector2i(i % 2, i / 2) * cell)
		target.save_png("res://docs/comic/hd/references/" + job.id + ".png")
	quit()
