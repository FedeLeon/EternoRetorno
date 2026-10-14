extends SceneTree
# Restore the selected generated drawings without repaints or resizing.
const BUILDINGS = ["market", "forge", "church", "expeditions", "refuge", "projects"]
func _initialize() -> void:
	for id in BUILDINGS:
		var source = "res://docs/base_camp/interiors/sources/%s.png" % id
		var destination = "res://assets/%s/interior.png" % id
		if not FileAccess.file_exists(source):
			push_error("Missing sketchbook source: " + source)
			quit(1)
			return
		DirAccess.make_dir_recursive_absolute(destination.get_base_dir())
		var result = DirAccess.copy_absolute(source,destination)
		if result != OK:
			push_error("Cannot copy interior: " + destination)
			quit(1)
			return
	quit()
