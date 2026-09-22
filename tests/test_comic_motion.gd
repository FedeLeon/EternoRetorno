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
		for variant in range(4):
			var id = "%s_%d" % [hero,variant]
			var effect = CutIn.play(host,hero,"attack",variant)
			check(effect.frame_grid == Vector2i(2,2), "animated " + id)
			var atlas = effect.frame_texture.atlas.get_image()
			check(atlas.get_size() == Vector2i(1200,800), "atlas dimensions " + id)
			var fingerprints: Array = []
			for i in range(4):
				var cell = atlas.get_region(Rect2i(i%2*600,i/2*400,600,400))
				fingerprints.append(hash(cell.get_data()))
				check(cell.get_pixel(0,0).a == 0 and cell.get_used_rect().size.x > 100, "transparent populated frame " + id)
			check(fingerprints.all(func(h): return fingerprints.count(h) == 1), "four distinct drawings " + id)
			var observed: Array = []
			var captured = false
			while is_instance_valid(effect) and not effect.is_queued_for_deletion():
				if effect.frame_index not in observed: observed.append(effect.frame_index)
				check(effect.frame_texture.region.end.x <= 1200 and effect.frame_texture.region.end.y <= 800, "atlas region valid")
				if effect.frame_index == 2 and not captured and DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("comic_motion/"+id+".png"))
					captured = true
				await process_frame
			check(observed == [0,1,2,3], "all four frames play in order " + id)
	var defense = CutIn.play(host,"guardian","defense")
	check(defense.frame_texture == null and defense.frame_grid == Vector2i.ONE, "defense keeps its artwork")
	await defense.finished
	print("COMIC MOTION: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
