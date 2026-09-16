extends RefCounted
# Disposable visual evidence. Never write generated captures into docs/.
static func path(relative: String) -> String:
	var output = "res://artifacts/" + relative
	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	FileAccess.open("res://artifacts/.gdignore", FileAccess.WRITE).close()
	return output
