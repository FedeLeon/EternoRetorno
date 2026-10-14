extends SceneTree
const Flow = preload("res://src/ui/combat_flow.gd")
var failures = 0
func _initialize(): call_deferred("run_tests")
func check(ok: bool, message: String):
	if not ok:
		failures += 1
		printerr(message)
func run_tests():
	var app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://unused-energy-timing.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "guardian"], 31)
	app.game.enter_node(0)
	app.game._start_combat(["goblin_warrior"])
	app.game.run.combat.hand = [{"id":"warrior_slash", "upgraded":false}]
	app.game.run.combat.energy = 3
	app.continue_run()
	Flow.run(app, 0, 0)
	check(app.combat_busy, "animation remains in progress")
	check(app.game.run.combat.energy == 2, "cost committed")
	check(app.layer.get_node("CombatHUD/EnergyNumber").value == 2, "energy visible before animation finishes")
	while app.combat_busy: await process_frame
	app.game.run.combat.hand = [{"id":"warrior_slash", "upgraded":false}]
	app.game.run.combat.energy = 0
	app.continue_run()
	Flow.run(app, 0, 0)
	check(not app.combat_busy, "unaffordable card rejected")
	check(app.layer.get_node("CombatHUD/EnergyNumber").value == 0, "rejected card preserves display")
	print("ENERGY TIMING: 5 checks / %d failures" % failures)
	quit(1 if failures else 0)
