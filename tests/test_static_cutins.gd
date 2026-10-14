extends SceneTree
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func _initialize() -> void:
	var signatures: Array = []
	for hero in ["warrior", "guardian", "rogue", "mage"]:
		for kind in ["attack", "defense"]:
			var id = hero + "_" + kind
			var texture: Texture2D = load("res://assets/comic/static/" + id + ".png")
			var image = texture.get_image()
			check(image.get_width() >= 1200 and image.get_height() >= 800, "HD image " + id)
			check(image.detect_alpha() != Image.ALPHA_NONE, "real alpha " + id)
			var clear = 0
			var solid = 0
			var samples = 0
			for y in range(0, image.get_height(), 24):
				for x in range(0, image.get_width(), 24):
					var alpha = image.get_pixel(x,y).a
					if alpha < 0.05: clear += 1
					if alpha > 0.7: solid += 1
					samples += 1
			check(float(clear)/samples > .20 and float(solid)/samples > .15, "populated transparent cutout " + id)
			var fingerprint = hash(image.get_data())
			check(not signatures.has(fingerprint), "distinct hero/action drawing " + id)
			signatures.append(fingerprint)
	check(not DirAccess.dir_exists_absolute("res://assets/comic/motion"), "obsolete foreground atlases removed")
	print("STATIC CUT-IN ASSETS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
