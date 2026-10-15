extends SceneTree
const Portrait = preload("res://src/ui/components/refuge_portrait.gd")
var checks = 0
var failures = 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: ", label)
func _initialize() -> void:
	var signatures = {}
	for hero in ["warrior", "guardian", "rogue", "mage"]:
		var small = Portrait.portrait(hero, true)
		var large = Portrait.portrait(hero, false)
		check(small.atlas.resource_path == "res://assets/heroes/identity/portraits/%s.png" % hero, "individual face portrait: " + hero)
		check(small.region == Rect2(Vector2.ZERO, small.atlas.get_size()), "complete face crop: " + hero)
		check(small.atlas.get_size() == Vector2(928, 464), "compact face cover dimensions: " + hero)
		check(large.atlas.resource_path == "res://assets/heroes/identity/postapocalyptic/%s.png" % hero, "civilian full-body master: " + hero)
		check(large.region == Rect2(Vector2.ZERO, large.atlas.get_size()), "large card preserves complete body: " + hero)
		var image = large.atlas.get_image()
		check(not image.is_invisible() and image.get_pixel(0, 0).a < 0.01, "transparent civilian illustration: " + hero)
		signatures[hash(image.get_data())] = true
	check(signatures.size() == 4, "four different civilian identities")
	print("COMPACT PORTRAITS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
