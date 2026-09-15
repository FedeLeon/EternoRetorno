class_name ERSaveStore
extends RefCounted

const VERSION = 1
var path: String
var last_error = ""

func _init(save_path: String = "user://eterno.save") -> void:
	path = save_path

func _valid(value: Variant) -> bool:
	return value is Dictionary and value.get("version") == VERSION and value.get("profile") is Dictionary and value.get("run") is Dictionary

func read() -> Dictionary:
	for candidate in [path, path + ".bak"]:
		if not FileAccess.file_exists(candidate):
			continue
		var file = FileAccess.open(candidate, FileAccess.READ)
		if file == null:
			continue
		var data = file.get_var(false)
		file.close()
		if _valid(data):
			return data
	last_error = "No se pudo recuperar el guardado." if FileAccess.file_exists(path) else ""
	return {}

func write(profile: Dictionary, run: Dictionary) -> bool:
	# One atomic envelope keeps permanent profile and active run in separate sections,
	# but commits them together: a crash cannot duplicate a victory or its rewards.
	var file = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		last_error = "No se pudo guardar. Revisá el espacio del dispositivo."
		return false
	file.store_var({"version": VERSION, "profile": profile, "run": run}, false)
	file.flush()
	var error = file.get_error()
	file.close()
	if error != OK:
		last_error = "No se pudo completar el guardado."
		return false
	if FileAccess.file_exists(path):
		DirAccess.copy_absolute(path, path + ".bak")
	error = DirAccess.rename_absolute(path + ".tmp", path)
	last_error = "" if error == OK else "No se pudo reemplazar el guardado."
	return error == OK
