class_name ERSaveStore
extends RefCounted

const VERSION = 1
var path: String
var last_error = ""
var recovered_from_backup = false

func _init(save_path: String = "user://eterno.save") -> void:
	path = save_path

func _valid(value: Variant) -> bool:
	return value is Dictionary and value.get("version") == VERSION and value.get("profile") is Dictionary and value.get("run") is Dictionary

func _read_candidate(candidate: String) -> Dictionary:
	var file = FileAccess.open(candidate, FileAccess.READ)
	if file == null: return {}
	var data = file.get_var(false)
	file.close()
	return data if _valid(data) else {}

func read() -> Dictionary:
	last_error = ""
	recovered_from_backup = false
	for candidate in [path, path + ".bak"]:
		if not FileAccess.file_exists(candidate):
			continue
		var data = _read_candidate(candidate)
		if not data.is_empty():
			recovered_from_backup = candidate != path
			return data
	last_error = "No se pudo recuperar el guardado." if FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak") else ""
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
	# Never replace a recoverable backup with a corrupt primary after recovery.
	if FileAccess.file_exists(path) and not _read_candidate(path).is_empty():
		error = DirAccess.copy_absolute(path, path + ".bak")
		if error != OK:
			last_error = "No se pudo conservar el respaldo. El guardado anterior sigue disponible."
			return false
	error = DirAccess.rename_absolute(path + ".tmp", path)
	last_error = "" if error == OK else "No se pudo reemplazar el guardado."
	return error == OK
