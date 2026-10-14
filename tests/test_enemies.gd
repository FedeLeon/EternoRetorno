extends SceneTree
const Visual = preload("res://src/enemy_sprite.gd")
const Game = preload("res://src/game.gd")
var checks = 0
var failures = 0
func _initialize() -> void:
	call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func run_tests() -> void:
	root.size = Vector2i(1280, 900)
	root.content_scale_size = Vector2i(1280, 900)
	var gallery = Control.new()
	root.add_child(gallery)
	var visuals = []
	var index = 0
	for id in Visual.entries():
		var v = Visual.new()
		v.visual_id = id
		v.position = Vector2((index % 8) * 160 + 16, (index / 8) * 125)
		v.size = Vector2(128, 106)
		gallery.add_child(v)
		visuals.append(v)
		var name_label = Label.new()
		name_label.text = Visual.entries()[id].name
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.position = v.position + Vector2(-14, 106)
		name_label.size = Vector2(156, 18)
		name_label.clip_text = true
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gallery.add_child(name_label)
		var img = v.sprite.texture.get_image()
		var cell_size = int(Visual.entries()[id].get("frame_size",128))
		check(img.get_size() == Vector2i(cell_size * (8 if v.has_motion_frames else 1), cell_size), id + " catalogue frame dimensions")
		check(v.has_motion_frames == (int(Visual.entries()[id].floor) in [1, 2, 3]), id + " active-floor motion coverage")
		if v.has_motion_frames:
			var unique: Array = []
			for frame_index in range(8):
				var frame = img.get_region(Rect2i(frame_index * cell_size, 0, cell_size, cell_size))
				check(frame.get_used_rect().size.x > 20 and frame.get_pixel(0, 0).a == 0, id + " motion frame content and alpha")
				var fingerprint = hash(frame.get_data())
				if fingerprint not in unique:
					unique.append(fingerprint)
				if id != "crypt_bat":
					var bottom = 0
					for y in range(cell_size):
						for x in range(cell_size):
							if frame.get_pixel(x, y).a >= 0.5:
								bottom = y + 1
					check(bottom == cell_size * 15 / 16, id + " stable grounded motion")
			check(unique.size() == 8, id + " eight distinct drawn poses")
		check(img.get_pixel(0, 0).a == 0 and img.get_used_rect().size.x > 10, id + " transparency and content")
		index += 1
	await create_timer(0.3).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("enemies/gallery.png"))
	for v in visuals:
		var scale_before = v.sprite.scale
		var frame_before = v.sprite.frame
		var position_before = v.sprite.position
		var changed = false
		# Ping-pong can revisit the same frame after a single sample; observe a cycle.
		for sample in range(5):
			v._process(0.13)
			changed = changed or v.sprite.scale != scale_before or v.sprite.frame != frame_before or v.sprite.position != position_before
		check(changed, v.visual_id + " idle changes")
		v.play_once("attack")
	await create_timer(0.5).timeout
	for v in visuals:
		check(not v.acting and not v.fallen, v.visual_id + " attack returns")
		v.play_once("hurt")
	await create_timer(0.3).timeout
	for v in visuals:
		check(not v.acting and v.sprite.modulate == Color.WHITE, v.visual_id + " hurt returns")
		v.play_once("death")
	await create_timer(1.5).timeout
	for v in visuals:
		check(v.fallen and not v.acting and not v.sprite.visible, v.visual_id + " death holds")
	gallery.free()
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-enemy-test.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "guardian"], 12)
	app.game.enter_node(0)
	for id in app.game.content.enemies:
		var def = app.game.content.enemies[id]
		app.game.run.combat.enemies = [{"id": id, "hp": def.hp, "max_hp": def.hp, "block": 0, "poison": 0, "intent": {"damage": 6, "target": 0}}]
		app.game.run.combat.hand = [{"id": "warrior_slash", "upgraded": false}]
		app.game.run.combat.energy = 3
		app.continue_run()
		await process_frame
		check(app.enemy_art[0] is Visual and app.enemy_art[0].visual_id == def.visual, id + " live mapping")
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("enemies/combat-" + id + ".png"))
		await app.animate_combat_action(0, 0)
		check(not app.combat_busy and app.game.run.combat.enemies[0].hp < def.hp, id + " damage and unlock")
	print("ENEMY CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
