extends SceneTree
const Game = preload("res://src/game.gd")
const Guide = preload("res://src/ui/guided_practice_navigation.gd")
const Lessons = preload("res://src/rules/guided_lessons.gd")
var app: Control
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ", message)
func click(node: Control) -> void:
	var point = node.get_global_rect().get_center()
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT; event.pressed = pressed; event.position = point
		root.push_input(event)
	await process_frame
func settled() -> void:
	while app.combat_busy: await process_frame
	await process_frame
func shot(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat_refinement/" + id + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-guided-original", false)
	root.add_child(app)
	app.game.new_run(["warrior", "guardian"], 89); app.game.enter_node(0)
	app.screen = "combat"; app.render()
	var original = app.game
	var run_before = original.run.duplicate(true)
	var profile_before = original.profile.duplicate(true)
	var rng_before = original.rng.state
	Guide.start(app)
	await process_frame
	check(app.game != original and not app.game.save_enabled, "practice is isolated and unsaved")
	check(not Lessons.ready(app.game), "block exercise requires actual play")
	await shot("lesson_block")
	await click(app.layer.get_node("CombatHand").get_child(0).get_child(0))
	await click(app.layer.get_node("HeroTarget0"))
	await settled()
	check(Lessons.ready(app.game), "defense played through real controls")
	await click(app.layer.find_child("LessonNext", true, false))
	check(app.game.run.guided_lesson.step == 1, "moves to enemy response")
	app.animate_combat_action(); await settled()
	check(Lessons.ready(app.game) and app.game.run.heroes[0].block == 0, "enemy turn consumes guard")
	Guide.next(app); await process_frame
	app.select_card(0)
	await process_frame
	await click(app.layer.get_node("ReserveCard"))
	await settled()
	check(Lessons.ready(app.game), "reservation required")
	Guide.next(app); await process_frame
	app.animate_combat_action(); await settled()
	check(Lessons.ready(app.game) and app.game.run.combat.get("reserved", []).is_empty(), "reserved card returns next turn")
	Guide.next(app); await process_frame
	check(not Lessons.ready(app.game), "synergy lesson cannot pass by viewing it")
	var combo = app.game.available_synergies()[0]
	var hand = app.layer.get_node("CombatHand").get_child(0)
	check(hand.get_children().all(func(c): return c.has_node("SynergyReady")), "both exact participating instances are marked")
	await shot("lesson_synergy")
	await click(app.layer.get_node("Synergy_" + combo.id))
	await click(app.layer.get_node("EnemyTarget0"))
	await settled()
	check(Lessons.ready(app.game), "real synergy completes exercise")
	Guide.next(app); await process_frame
	check(app.game == original and app.training_original == null and app.screen == "combat", "returns to exact original adventure")
	check(original.run == run_before and original.rng.state == rng_before, "real run and RNG untouched")
	profile_before.tutorial_complete = true; profile_before.guided_practice_complete = true
	check(original.profile == profile_before, "only tutorial completion changes profile")
	Guide.start(app); await process_frame
	Guide.finish(app, false); await process_frame
	check(app.game == original and original.run == run_before, "exiting practice also preserves adventure")
	print("GUIDED PRACTICE: %d checks / %d failures" % [checks, failures])
	app.queue_free(); await process_frame
	quit(1 if failures else 0)
