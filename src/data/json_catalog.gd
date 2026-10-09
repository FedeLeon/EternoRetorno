extends RefCounted
## Process-local source cache. Callers always receive independent mutable copies.
static var _sources: Dictionary = {}
static var _errors: Dictionary = {}
static var _reads: Dictionary = {}

static func dictionary(path: String) -> Dictionary:
	var value = _read(path, TYPE_DICTIONARY)
	return value.duplicate(true) if value is Dictionary else {}

static func array(path: String) -> Array:
	var value = _read(path, TYPE_ARRAY)
	return value.duplicate(true) if value is Array else []

static func _read(path: String, expected_type: int) -> Variant:
	if _sources.has(path):
		if typeof(_sources[path]) == expected_type:
			_errors.erase(path)
			return _sources[path]
		_errors[path] = "Root type mismatch: " + path
		return null
	_reads[path] = int(_reads.get(path, 0)) + 1
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		_errors[path] = "Cannot read %s (error %d)" % [path, FileAccess.get_open_error()]
		return null
	var text = file.get_as_text()
	file.close()
	var parser = JSON.new()
	if parser.parse(text) != OK:
		_errors[path] = "%s:%d: %s" % [path, parser.get_error_line(), parser.get_error_message()]
		return null
	if typeof(parser.data) != expected_type:
		_errors[path] = "Root type mismatch: " + path
		return null
	_errors.erase(path)
	_sources[path] = parser.data
	return _sources[path]

static func error_for(path: String) -> String:
	return _errors.get(path, "")

static func reads(path: String) -> int:
	return int(_reads.get(path, 0))

static func clear(path: String = "") -> void:
	if path.is_empty():
		_sources.clear(); _errors.clear(); _reads.clear()
	else:
		_sources.erase(path); _errors.erase(path); _reads.erase(path)
