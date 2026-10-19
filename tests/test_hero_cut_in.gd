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
	root.size = Vector2i(1280, 720)
	var host = Control.new()
	root.add_child(host)
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop = TextureRect.new()
	backdrop.texture = preload("res://assets/dungeon/combat.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(backdrop)
	for hero in CutIn.COLORS:
		for kind in ["attack", "defense"]:
			var effect = CutIn.play(host, hero, kind)
			await process_frame
			effect.set_process(false)
			effect.elapsed = 0.0
			check(effect.picture.texture != null and not effect.picture.texture is AtlasTexture, "single full image " + hero + kind)
			check(effect.static_illustration and effect.frame_texture == null and effect.frame_grid == Vector2i.ONE, "no pose playback " + hero + kind)
			check(effect.size == host.size and effect.z_index == 150 and effect.mouse_filter == Control.MOUSE_FILTER_IGNORE, "nonblocking foreground " + hero + kind)
			check(effect.hero_fx != null and effect.hero_fx.get_index() < effect.picture.get_index(), "particles behind character " + hero + kind)
			check(effect.defensive_effect == (kind == "defense"), "matching effect " + hero + kind)
			check(effect.hero_fx.full_view_rays and effect.hero_fx.size==host.size,"hero light canvas covers full view")
			effect._process(0.0) # Initialize the real lower-left origin before measuring coverage.
			var light = effect.hero_fx
			var origin = light.area.position + light.area.size*Vector2(0.60,0.48)
			for i in range(16):
				var direction = Vector2.from_angle(i*TAU/16.0)
				var tip = origin + direction*light.ray_reach(origin,light.area.size.y,i)*0.85
				check(not Rect2(Vector2.ZERO,host.size).grow(8).has_point(tip),"ray tip stays beyond viewport even at shortest phase")
			var position: Vector2 = effect.picture.position
			var texture: Texture2D = effect.picture.texture
			var completed = [0]
			effect.finished.connect(func(): completed[0] += 1)
			for tick in range(3):
				effect._process(0.24)
				check(effect.picture.position == position and effect.picture.scale == Vector2.ONE, "still image transform " + hero + kind)
				check(effect.picture.texture == texture and effect.frame_index == 0 and effect.picture.self_modulate == Color.WHITE, "unchanged artwork " + hero + kind)
			check(position.x < 0 and is_equal_approx(position.y + effect.picture.size.y, host.size.y * 1.15), "lower left framing " + hero + kind)
			check(position.y >= 355 and effect.picture.size.y < host.size.y*.66,"foreground leaves battle actors visible")
			check(effect.impact_panel.position==position and effect.impact_panel.size==effect.picture.size,"comic details stay beside the lower-left illustration")
			check(effect.hero_fx.elapsed > 0.0 and effect.hero_fx.area.size.x > 0, "live background effects " + hero + kind)
			if DisplayServer.get_name() != "headless":
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("comic_static/"+hero+"_"+kind+".png"))
			effect._process(0.25)
			effect._process(0.25)
			check(completed[0] == 1 and effect.modulate.a == 0, "single completion even on slow frame " + hero + kind)
			await process_frame
			check(not is_instance_valid(effect), "effect freed " + hero + kind)
	# Each hit remains static but successive hits choose different artwork.
	var combo_paths = {}
	for _hit in range(3):
		var effect = CutIn.play(host, "warrior", "attack")
		await process_frame
		combo_paths[effect.texture_path] = true
		check(effect.static_illustration, "combo remains static")
		effect.queue_free()
		await process_frame
	check(combo_paths.size() == 3, "three different static illustrations for combo hits")
	check(CutIn.play(host, "missing") == null and CutIn.play(host, "warrior", "missing") == null, "invalid request ignored")
	host.queue_free()
	await process_frame
	print("STATIC HERO CUT-IN: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
