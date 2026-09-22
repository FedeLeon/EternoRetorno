extends SceneTree
const Game = preload("res://src/game.gd")
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr(message)
func run_tests() -> void:
	var path = "user://end-adventure-test.save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	var game = Game.new(path, true)
	game.profile.buildings.expeditions = true
	var offers = game.profile.expeditions.offers.duplicate()
	game.profile.expeditions.selected = offers[0]
	game.new_run(["warrior","cleric"],31)
	game.enter_node(0)
	var cycle = game.profile.expeditions.cycle
	var souls = game.profile.souls
	var app = load("res://main.tscn").instantiate()
	app.game = game
	root.add_child(app)
	app.continue_run()
	await process_frame
	app.pause_menu()
	app.overlay.get_node("EndAdventure").pressed.emit()
	app.overlay.get_node("CancelEndAdventure").pressed.emit()
	check(app.active_run() and game.profile.expeditions.cycle == cycle, "cancel preserves adventure and contract")
	app.overlay.get_node("EndAdventure").pressed.emit()
	app.overlay.get_node("ConfirmEndAdventure").pressed.emit()
	check(not app.active_run() and app.screen == "base_camp", "ends and returns to camp")
	check(game.profile.expeditions.cycle == cycle + 1 and game.profile.expeditions.selected == "", "refreshes contracts once")
	check(game.profile.expeditions.offers.all(func(id): return id not in offers), "three new offers")
	check(game.profile.souls == souls and game.profile.victories == 0, "preserves souls without victory")
	check(game.run.deck.is_empty() and game.run.combat.is_empty(), "clears run equipment and combat")
	check(not game.end_adventure() and game.profile.expeditions.cycle == cycle + 1, "cannot settle twice")
	var loaded = Game.new(path,true)
	check(loaded.run.phase == "defeat" and loaded.profile.expeditions == game.profile.expeditions, "conclusion persisted")
	check(preload("res://src/rules/expeditions.gd").select(loaded.profile,loaded.run,loaded.profile.expeditions.offers[0]), "new contract selectable")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("END ADVENTURE FAILURES: ", failures)
	quit(1 if failures else 0)
