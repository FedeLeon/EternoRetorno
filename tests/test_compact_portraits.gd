extends SceneTree
const Portrait = preload("res://src/ui/components/refuge_portrait.gd")
var checks = 0
var failures = 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures += 1; printerr("FAIL: ",label)
func _initialize() -> void:
	var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/portraits/2026-10-13/vertical_baseline.json"))
	for path in baseline:
		var hash = HashingContext.new()
		hash.start(HashingContext.HASH_SHA256)
		hash.update(FileAccess.get_file_as_bytes("res://"+path))
		check(hash.finish().hex_encode()==baseline[path],"vertical source unchanged: "+path)
	var original_regions = {
		"warrior":Rect2(0.045,0.04,0.205,0.54),
		"guardian":Rect2(0.29,0.06,0.21,0.54),
		"mage":Rect2(0.79,0.06,0.205,0.54),
		"rogue":Rect2(0.22,0.035,0.56,0.52)}
	for hero in original_regions:
		var small = Portrait.portrait(hero,true)
		var large = Portrait.portrait(hero,false)
		check(small.atlas.resource_path=="res://assets/heroes/identity/portraits/%s.png" % hero,"small card has its own face: "+hero)
		check(small.region==Rect2(Vector2.ZERO,small.atlas.get_size()),"complete face image without card crop: "+hero)
		check(large.atlas.resource_path==("res://assets/heroes/identity/rogue_unmasked.png" if hero=="rogue" else "res://assets/heroes/identity/sketchbook.png"),"large card keeps full-body source: "+hero)
		var region: Rect2 = original_regions[hero]
		var expected = Rect2(region.position*large.atlas.get_size(),region.size*large.atlas.get_size())
		check(large.region.is_equal_approx(expected),"large card keeps previous framing: "+hero)
		var source = Image.load_from_file("res://docs/portraits/2026-10-13/sources/%s.png" % hero)
		check(absf(float(source.get_width())/source.get_height()-small.atlas.get_width()/float(small.atlas.get_height()))<0.01,"proportional source sizing: "+hero)
	print("COMPACT PORTRAITS: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
