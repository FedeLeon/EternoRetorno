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
			var expected_bottom = host.size.y * 1.12
			if effect.picture.position.x > host.size.x * 0.03 or not is_equal_approx(effect.picture.position.y + effect.picture.size.y, expected_bottom):
				failures += 1
			if effect.picture.position.x >= 0:
				failures += 1
			if DisplayServer.get_name() != "headless" and hero == "warrior" and kind == "attack":
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat/comic.png"))
			await effect.finished
			await process_frame
			if is_instance_valid(effect):
				failures += 1
	# Four attacks per hero rotate without repeating within a two/three-hit combo.
	for hero in CutIn.COLORS:
		var paths: Array = []
		for index in range(5):
			var effect = CutIn.play(host, hero)
			await process_frame
			if effect.picture.texture == null: failures += 1
			paths.append(effect.texture_path)
			effect.queue_free()
			await process_frame
		if paths.slice(0, 4).size() != 4 or paths[0] != paths[4]: failures += 1
		for first in range(4):
			for second in range(first + 1, 4):
				if paths[first] == paths[second]: failures += 1
	# A slow render frame must advance at most one pose; fade uses the same clock.
	var slow = CutIn.play(host, "warrior", "defense")
	slow.set_process(false)
	var completed = [0]
	slow.finished.connect(func(): completed[0] += 1)
	var observed = [slow.frame_index]
	for tick in range(20):
		slow._process(0.25)
		if slow.frame_index != observed.back(): observed.append(slow.frame_index)
		if slow.is_queued_for_deletion(): break
	if observed != range(16) or completed[0] != 1 or slow.modulate.a != 0.0:
		printerr("Slow-frame regression: ", observed, " completed=", completed[0], " alpha=", slow.modulate.a)
		failures += 1
	await process_frame
	if is_instance_valid(slow):
		printerr("Slow-frame effect was not freed")
		failures += 1
	if CutIn.play(host, "missing") != null:
		failures += 1
	print("COMIC: 6 heroes, 4 attack variants + defense, rotation, cleanup, missing ID | FAILURES: ", failures)
	quit(1 if failures else 0)
