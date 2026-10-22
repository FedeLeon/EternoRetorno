extends SceneTree
const Game = preload("res://src/game.gd")
var app: Control
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ", message)
func setup() -> void:
	app.game.new_run(["rogue", "mage"], 47)
	app.game.enter_node(0)
	app.game._start_combat(["skeleton"])
	app.game.run.combat.hand.clear()
	app.game.run.combat.enemies[0].intent = {"damage":0, "block":2, "target":0}
	app.continue_run()
	await process_frame
func capture(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat_ui_2026_10_18/" + id + ".png"))
func observe(expected: Array[String]) -> void:
	var seen: Array[String] = []
	var captured: Array[String] = []
	var committed = app.game.run.duplicate(true)
	var rng = app.game.rng.state
	var frames = 0
	while app.combat_busy and frames < 12000:
		frames += 1
		var banner = app.layer.get_node_or_null("TurnAnnouncement")
		if banner != null:
			var caption = banner.get_node("Caption")
			check(caption.texture.resource_path.ends_with("enemy_turn.png" if banner.enemy_turn else "player_turn.png"),"correct illustrated turn lettering")
			var text: String = "Turno del enemigo" if banner.enemy_turn else "Tu turno · %d"%banner.get_node("TurnNumber").value
			if seen.is_empty() or seen.back() != text:
				seen.append(text)
				app.animate_combat_action()
				check(app.game.run == committed, "double end turn is ignored during announcement")
			if banner.modulate.a > 0.95 and text not in captured:
				captured.append(text)
				await capture("enemy-turn" if banner.enemy_turn else "player-turn")
		await process_frame
	check(frames < 12000 and not app.combat_busy, "presentation returns control")
	check(seen == expected, "correct order, text and turn number: " + str(seen))
	check(app.game.run == committed and app.game.rng.state == rng, "announcements do not resolve, save or consume RNG again")
	check(not app.layer.has_node("TurnAnnouncement"), "announcement removed after playback")
func verify() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-turn-announcements", false)
	app.game.profile.tutorial_complete = true
	root.add_child(app)
	await setup()
	var before = app.game.run.duplicate(true)
	app.combat_busy = true
	app.animate_combat_action()
	check(app.game.run == before and not app.layer.has_node("TurnAnnouncement"), "rejected action has no announcement")
	app.combat_busy = false
	for number in [2, 3]:
		app.animate_combat_action()
		check(app.game.run.combat.turn == number and app.combat_busy, "turn resolves before announcement")
		await observe(["Turno del enemigo", "Tu turno · %d" % number])
	# Poison can end the battle before the enemy acts; never announce a player turn.
	await setup()
	app.game.run.combat.enemies[0].hp = 1
	app.game.run.combat.enemies[0].poison = 99
	app.render(); await process_frame
	app.animate_combat_action()
	await observe(["Turno del enemigo"])
	check(app.game.run.phase == "reward", "poison victory still reaches rewards")
	await setup()
	for hero in app.game.run.heroes: hero.hp = 1; hero.block = 0
	app.game.run.combat.enemies[0].intent = {"damage":999,"block":0,"target":0,"all":true}
	app.render(); await process_frame
	app.animate_combat_action()
	await observe(["Turno del enemigo"])
	check(app.game.run.phase != "combat", "defeat does not announce a playable turn")
	app.queue_free(); await process_frame; await process_frame
	print("TURN ANNOUNCEMENTS: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
