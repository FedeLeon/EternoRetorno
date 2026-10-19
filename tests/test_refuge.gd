extends SceneTree
const Game = preload("res://src/game.gd")
const Starters = preload("res://src/rules/starter_decks.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr(text)
func click(node: Control) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = node.get_global_rect().get_center()
		root.push_input(event)
	await process_frame
func shot(name: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("refuge/" + name + ".png"))
func run_tests() -> void:
	var path = "user://refuge-test.save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	var game = Game.new(path, true)
	game.new_run(["warrior", "mage"], 42)
	var previous = game.run.duplicate(true)
	var souls = game.profile.souls
	for hero in game.content.heroes:
		var original = game.content.heroes[hero].starter
		check(Starters.deck(game.content, {}, hero) == original, "legacy profile preserves original " + hero)
		for amount in range(2, 7):
			check(game.configure_starter(hero, amount), "valid basic distribution")
			var deck = Starters.deck(game.content, game.profile, hero)
			check(deck.size() == 10 and deck.count(original[0]) == amount and deck.count(original[4]) == 8 - amount, "ten cards with paired basic changes")
			check(deck.slice(8) == original.slice(8), "class cards untouched")
		check(not game.configure_starter(hero, 1) and not game.configure_starter(hero, 7), "reject out of bounds")
	check(not game.configure_starter("invalid", 4), "reject unknown hero")
	check(game.run == previous and game.profile.souls == souls, "configuration leaves active run and souls unchanged")
	var loaded = Game.new(path, true)
	check(loaded.profile.starter_attacks == game.profile.starter_attacks and loaded.run == previous, "save reload keeps config and run")
	loaded.new_run(["warrior", "mage"], 42)
	check(loaded.run.deck.size() == 20 and loaded.run.deck.filter(func(c): return c.id == "warrior_slash").size() == 6, "new adventure uses configured 20-card deck")
	check(Starters.attack_count({"starter_attacks": []}, "mage") == 4, "malformed field falls back")
	check(Starters.attack_count({"starter_attacks":{"mage":"bad"}}, "mage") == 4, "malformed count falls back")

	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-refuge-ui.save", false)
	root.add_child(app)
	app.open_base_camp()
	await process_frame
	await click(app.layer.get_node("CampTent"))
	check(app.screen == "refuge", "camp tent opens refuge")
	var view = app.layer.get_node("RefugeScreen")
	check(view.body.find_children("RefugeHero_*", "Button", true, false).size() == 4, "four active hero cards")
	await shot("heroes")
	for hero in preload("res://src/rules/hero_roster.gd").ids(app.game.content.heroes):
		var portrait = view.body.get_node("RefugeHero_" + hero)
		check(portrait.get_node("ComicPortrait").texture is AtlasTexture, "reuse cropped comic art")
		await click(portrait)
		check(view.selected == hero and view.body.get_node("SaveStarter").disabled, "correct hero editor, no pending changes")
		await click(view.body.get_node("More0"))
		check(view.attacks == 5 and view.body.get_node("Copies1").text == "3 copias", "attack addition removes defense")
		check(not app.game.profile.has("starter_attacks") or not app.game.profile.starter_attacks.has(hero), "draft not persisted")
		await click(view.body.get_node("SaveStarter"))
		check(app.game.profile.starter_attacks[hero] == 5 and view.body.get_node("SaveStarter").disabled, "save confirmed")
		if hero == "warrior": await shot("editor")
		await click(view.body.get_node("RestoreStarter"))
		check(view.attacks == 4 and not view.body.get_node("SaveStarter").disabled, "reset previews original")
		await click(view.body.get_node("SaveStarter"))
		check(app.game.profile.starter_attacks[hero] == 4, "reset persists on confirm")
		await click(app.layer.get_node("HeaderBack"))
		check(view.selected == "", "back to hero cards")
	app.back()
	check(app.screen == "base_camp", "return to camp")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("REFUGE CHECKS: ", checks, " | FAILURES: ", failures)
	quit(1 if failures else 0)
