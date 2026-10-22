extends SceneTree
## Crop the authored 0-9 brush atlas into a baseline-aligned number bank.
const BASE = "res://art_sources/turn_digits_2026_10_22/"
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")

func write_json(path: String, value: Variant) -> void:
	FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(value,"\t",false)+"\n")

func _initialize() -> void:
	var record: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASE+"generation.json"))
	var source: String = "res://"+record.source
	var glyphs = Pack.actor_cells(source,5,2)
	if glyphs.size()!=10:
		push_error("Expected ten brush numerals")
		quit(1)
		return
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/art_direction/postapocalyptic/assets.json"))
	var extraction: Dictionary = {}
	for i in 10:
		var glyph: Image = glyphs[i]
		var ratio = minf(152.0/glyph.get_width(),128.0/glyph.get_height())
		glyph.resize(maxi(1,roundi(glyph.get_width()*ratio)),maxi(1,roundi(glyph.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
		var bounds = Pack.bounds(glyph,.5)
		var frame = Image.create(160,144,false,Image.FORMAT_RGBA8)
		frame.fill(Color.TRANSPARENT)
		frame.blit_rect(glyph,Rect2i(Vector2i.ZERO,glyph.get_size()),Vector2i(80-bounds.position.x-bounds.size.x/2,136-bounds.end.y))
		frame.fix_alpha_edges()
		var relative = "assets/battle_turns/digits/%d.png"%i
		Pack.save(frame,"res://"+relative)
		manifest[relative] = {"sha256":FileAccess.get_sha256("res://"+relative),"source":record.source,"source_sha256":FileAccess.get_sha256(source),"style":"postapocalyptic_comic","processing":"Generated brush numeral, transparent crop and proportional reduction; common baseline","outline_baked":true,"origin":{"record":"art_sources/turn_digits_2026_10_22/generation.json","digit":i}}
		extraction[str(i)] = {"runtime":relative,"sha256":manifest[relative].sha256,"baseline":136}
	write_json(BASE+"extraction.json",extraction)
	write_json("res://art_sources/art_direction/postapocalyptic/assets.json",manifest)
	print("TURN DIGITS: 10 authored glyphs imported")
	quit()
