extends SceneTree
const Game = preload("res://src/game.gd")
var app: Control
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func _initialize() -> void:
	call_deferred("run_tests")
func click(index: int) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = app.CAMP_POSITIONS[index] - Vector2(0, 50)
		root.push_input(event)
	await process_frame
func capture(name: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("camp/" + name + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-camp-test.save", false)
	root.add_child(app)
	app.open_selection()
	await create_timer(0.2).timeout
	var fire = app.layer.get_node("Campfire")
	check(fire.flame.sprite_frames.get_frame_count("default") == 24, "natural fire has twenty-four frames")
	for id in preload("res://src/rules/hero_roster.gd").ids(app.game.content.heroes):
		var seat = app.layer.get_node("CampHero_" + id + "/SeatedHero")
		check(seat.texture is AtlasTexture and seat.texture.atlas.resource_path == "res://assets/rest/%s.png" % id, "selection reuses seated rest artwork")
		check(seat.material is ShaderMaterial, "seated hero receives animated firelight")
		check(is_equal_approx(seat.position.y + seat.size.y, 216), "seated boots anchored to the shared floor")
		check(seat.position.y >= 0 and seat.position.y + seat.size.y < seat.get_parent().size.y, "whole seated illustration is inside its touch target")
		check(seat.flip_h == (seat.get_parent().position.x > 640), "seated hero faces the fire")
	check(fire.barrel is Sprite2D and not fire.barrel is AnimatedSprite2D, "barrel is a static body")
	var barrel_texture = fire.barrel.texture
	var barrel_transform = fire.barrel.transform
	var flame_position = fire.flame.position
	var drawings = {}
	var raw_flames = Image.new()
	raw_flames.load_png_from_buffer(FileAccess.get_file_as_bytes("res://assets/camp/fire-flames.png"))
	for frame in range(24):
		fire.flame.pause()
		fire.flame.frame = frame
		var texture = fire.flame.sprite_frames.get_frame_texture("default", frame)
		check(texture.atlas.resource_path.ends_with("fire-flames.png"), "only flame art advances")
		drawings[hash(raw_flames.get_region(Rect2i(texture.region)).get_data())] = true
		check(fire.barrel.texture == barrel_texture and fire.barrel.transform == barrel_transform, "barrel does not move across the whole cycle")
		check(fire.flame.position == flame_position and fire.flame.offset == Vector2.ZERO, "flame root remains above the same rim")
	check(drawings.size() == 24, "twenty-four distinct flame-only drawings")
	fire.flame.play()
	var first = fire.flame.frame
	await capture("camp-first")
	await create_timer(0.27).timeout
	check(fire.flame.frame != first and fire.elapsed > 0.4, "fire frames and sparks advance")
	await capture("camp-second")
	var ids = preload("res://src/rules/hero_roster.gd").ids(app.game.content.heroes)
	for i in range(ids.size()):
		for j in range(i + 1, ids.size()):
			app.selected_party.clear()
			app.render()
			await process_frame
			await click(i)
			await click(j)
			check(app.selected_party == [ids[i], ids[j]], "pair selectable %d %d" % [i, j])
			await click((j + 1) % ids.size() if (j + 1) % ids.size() != i else (j + 2) % ids.size())
			check(app.selected_party.size() == 2, "third choice rejected")
			await click(i)
			check(app.selected_party == [ids[j]], "deselect by touch")
	app.selected_party = ["warrior", "mage"]
	app.render()
	await create_timer(0.2).timeout
	await capture("camp-selected")
	app.begin()
	app.overlay.get_node("StartDungeon1").pressed.emit()
	app.overlay.get_node("StartAdventure").pressed.emit()
	for hero in ["warrior","mage"]:
		await process_frame
		check(app.has_node("CinematicPlayer"),"story shown for chosen hero")
		app.get_node("CinematicPlayer").finish()
	await process_frame
	check(app.screen == "combat" and app.game.run.current == 0 and app.game.run.party == ["warrior", "mage"], "chosen pair enters dungeon")
	print("CAMP CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
