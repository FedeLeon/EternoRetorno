extends SceneTree
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func click(button: Control) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = button.get_global_rect().get_center()
		root.push_input(event)
	await process_frame
func enter_rest(app: Control) -> void:
	app.game.run.current = app.game.run.nodes.filter(func(n): return n.kind == "rest")[0].id
	app.game.run.phase = "room"
	app.continue_run()
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://unused-rest.save", false)
	root.add_child(app)
	var ids = ["warrior", "guardian", "rogue", "mage", "cleric", "ranger"]
	for pair in range(3):
		app.game.new_run([ids[pair * 2], ids[pair * 2 + 1]], 42)
		for hero in app.game.run.heroes: hero.hp = 10
		enter_rest(app)
		await process_frame
		var view = app.layer.get_node("RestScreen")
		check(not view.get_node("Hero0").flip_h and view.get_node("Hero1").flip_h, "heroes face the campfire")
		for i in range(2):
			var image = view.get_node("Hero%d" % i).texture.get_image()
			check(image.detect_alpha() != Image.ALPHA_NONE, "seated hero has transparent background")
			check(view.get_node("Health%d" % i).position.y < view.get_node("Hero%d" % i).position.y, "health above each hero")
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("rest/pair%d.png" % pair))
		var before = app.game.run.duplicate(true)
		await click(view.get_node("Upgrade"))
		check(app.screen == "deck" and app.upgrade_mode, "upgrade opens card chooser")
		check(app.game.run == before, "opening upgrade does not consume rest")
		app.back()
		await process_frame
		check(app.layer.has_node("RestScreen") and app.game.run == before, "cancel returns to same rest")
		await click(app.layer.get_node("RestScreen/Heal"))
		check(app.screen == "map", "healing returns to map")
		for hero in app.game.run.heroes:
			check(hero.hp == mini(hero.max_hp, 10 + ceili(hero.max_hp * 0.3)), "healing keeps 30 percent rule")
		check(not app.game.rest(true), "rest cannot be consumed twice")
	enter_rest(app)
	for card in app.game.run.deck: card.upgraded = true
	app.render()
	await process_frame
	check(app.layer.get_node("RestScreen/Upgrade").disabled, "no upgrade when every card is upgraded")
	print("REST CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
