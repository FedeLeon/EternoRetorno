extends SceneTree
# Geometry only: 24 flame-only drawings, one shared scale and a fixed root.
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
const SOURCE = "res://art_sources/base_camp/stable_fire/sources/flames.png"
const TARGET = "res://assets/camp/fire-flames.png"
func _initialize() -> void:
	var source = Image.load_from_file(SOURCE)
	if source == null or source.detect_alpha() == Image.ALPHA_NONE:
		push_error("Flames require real transparency")
		quit(1)
		return
	var poses = Pack.cells(SOURCE, 6, 4)
	if poses.size() != 24:
		push_error("Expected 24 isolated flame drawings")
		quit(1)
		return
	var ratio = 1000.0
	for pose in poses:
		ratio = minf(ratio, minf(160.0 / pose.get_width(), 124.0 / pose.get_height()))
	Pack.save(Pack.pack(poses, 6, 256, ratio, 240), TARGET)
	var path = "res://art_sources/art_direction/postapocalyptic/assets.json"
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	manifest[TARGET.trim_prefix("res://")] = {"sha256":FileAccess.get_sha256(TARGET), "source":SOURCE.trim_prefix("res://"), "source_sha256":FileAccess.get_sha256(SOURCE), "style":"postapocalyptic_comic", "tool":"image_gen.imagegen", "processing":"6x4 flame-only bank, shared proportional scale, baseline 240, barrel stays separate", "provenance":"art_sources/base_camp/stable_fire/generation.json"}
	FileAccess.open(path, FileAccess.WRITE).store_string(JSON.stringify(manifest, "\t") + "\n")
	print("CAMP FLAMES: 24 drawings, fixed baseline 240")
	quit()
