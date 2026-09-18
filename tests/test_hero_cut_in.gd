extends SceneTree
const CutIn = preload("res://src/presentation/hero_cut_in.gd")
var failures = 0
func _initialize() -> void:
	call_deferred("run_tests")
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var host = Control.new()
	root.add_child(host)
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop = TextureRect.new()
	backdrop.texture = preload("res://assets/dungeon/combat.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(backdrop)
	for kind in ["attack", "defense"]:
		for hero in CutIn.COLORS:
			var effect = CutIn.play(host, hero, kind)
			await process_frame
			if effect.picture.texture == null or effect.size.x <= 0 or effect.z_index >= 200:
				failures += 1
			await create_timer(0.24).timeout
			if effect.picture.position.x > host.size.x * 0.03 or not is_equal_approx(effect.picture.position.y + effect.picture.size.y, host.size.y):
				failures += 1
			if DisplayServer.get_name() != "headless" and hero == "warrior" and kind == "defense":
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat/comic.png"))
			await effect.finished
			await process_frame
			if is_instance_valid(effect):
				failures += 1
	if CutIn.play(host, "missing") != null:
		failures += 1
	print("COMIC: 6 heroes, attack + defense, cleanup, missing ID | FAILURES: ", failures)
	quit(1 if failures else 0)
