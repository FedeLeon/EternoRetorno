extends SceneTree
const CutIn = preload("res://src/presentation/hero_cut_in.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	var host = Control.new()
	root.add_child(host)
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop = TextureRect.new()
	backdrop.texture = preload("res://assets/dungeon/combat.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(backdrop)
	for hero in CutIn.COLORS:
		for variant in range(5):
			var id = "%s_%d" % [hero,variant] if variant < 4 else hero + "_defense"
			if not OS.get_cmdline_user_args().is_empty() and id not in OS.get_cmdline_user_args(): continue
			# CPU/GPU image reads and hashes must not stall the animation under test.
			var atlas = load("res://assets/comic/motion/" + id + ".png").get_image()
			check(atlas.get_size() == Vector2i(3072,2048), "atlas dimensions " + id)
			var fingerprints: Array = []
			for i in range(16):
				var cell = atlas.get_region(Rect2i(i%4*768,i/4*512,768,512))
				fingerprints.append(hash(cell.get_data()))
				check(cell.get_pixel(0,0).a == 0 and cell.get_used_rect().size.x > 100, "transparent populated frame " + id)
				var clear = 0
				var samples = 0
				for y in range(20, 492, 20):
					for x in range(20, 748, 20):
						samples += 1
						if cell.get_pixel(x, y).a < 0.05: clear += 1
				check(float(clear) / samples > 0.20, "no opaque rectangular backdrop " + id)
			check(fingerprints.all(func(h): return fingerprints.count(h) == 1), "sixteen distinct drawings " + id)
			await process_frame
			var effect = CutIn.play(host,hero,"attack" if variant < 4 else "defense",mini(variant,3))
			check(effect.frame_grid == Vector2i(4,4), "animated " + id)
			check(effect.hero_fx != null and effect.hero_fx.mouse_filter == Control.MOUSE_FILTER_IGNORE, "nonblocking hero particles " + id)
			check(effect.defensive_effect == (variant == 4), "effect follows action " + id)
			var observed: Array = []
			var captured = false
			var capture: Image
			while is_instance_valid(effect) and not effect.is_queued_for_deletion():
				if effect.frame_index not in observed: observed.append(effect.frame_index)
				check(effect.frame_texture.region.end.x <= 3072 and effect.frame_texture.region.end.y <= 2048, "atlas region valid")
				if effect.frame_index == 8 and not captured and DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					capture = root.get_texture().get_image()
					captured = true
					continue # frame_post_draw already yielded; do not skip the next frame.
				await process_frame
			check(observed == range(16), "all sixteen frames play in order " + id + ": " + str(observed))
			if capture != null:
				capture.save_png(preload("res://tests/artifacts.gd").path("comic_motion/"+id+".png"))
	print("COMIC MOTION: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
