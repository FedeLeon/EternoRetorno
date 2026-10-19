extends RefCounted
## Offline import guard: historical jobs must not reinstall deleted runtime assets.
static var resources: Dictionary = {}
static func contains(path: String) -> bool:
	if resources.is_empty():
		var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/retired_resources.json"))
		for resource in report.resources:
			resources[resource] = true
	return resources.has(path.trim_prefix("res://"))
