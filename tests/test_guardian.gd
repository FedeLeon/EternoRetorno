extends SceneTree
const Game = preload("res://src/game.gd")
const Guardian = preload("res://src/guardian_sprite.gd")
var app: Control
var checks = 0
var failures = 0
const SAVE = "user://guardian-animation-test.save"
func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: ", description)
func _initialize() -> void:
	call_deferred("run_tests")
func shot(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/guardian/" + name + ".png")
func settled() -> void:
	while app.combat_busy:
		await process_frame
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(SAVE + suffix)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new(SAVE, true)
	root.add_child(app)
	for animation in ["idle", "attack", "bash", "guard", "hurt", "death", "revive"]:
		check(Guardian.frames().get_frame_count(animation) == 6, "six frames for " + animation)
		check(Guardian.frames().get_animation_loop(animation) == (animation == "idle"), "loop policy " + animation)
	var atlas = Guardian.SHEET.get_image()
	check(atlas.get_size() == Vector2i(384, 384), "64px atlas grid")
	check(atlas.get_pixel(0, 0).a == 0, "true transparent alpha")
	for row in range(6):
		for column in range(6):
			var frame = atlas.get_region(Rect2i(column * 64, row * 64, 64, 64))
			var bounds = frame.get_used_rect()
			# Visible pixels anchor the pose; ignore nearly transparent specks.
			var bottom = 0
			for y in range(64):
				for x in range(64):
					if frame.get_pixel(x, y).a >= 0.5:
						bottom = y + 1
			check(bottom == 60 and bounds.size.x > 0, "visible baseline row %d frame %d" % [row, column])
	app.open_selection()
	await create_timer(0.2).timeout
	await shot("selection")
	app.game.new_run(["guardian", "cleric"], 42)
	app.game.enter_node(0)
	app.game.run.combat.enemies[0].hp = 100
	app.game.run.combat.enemies[0].max_hp = 100
	app.game.run.combat.hand = [{"id": "guardian_strike", "upgraded": false}]
	app.continue_run()
	await create_timer(0.2).timeout
	await shot("idle")
	app.animate_combat_action(0, 0)
	check(app.combat_busy, "input locked during attack")
	check(app.hero_art[0].sprite.animation == "attack", "counterattack uses flail")
	var hp = app.game.run.combat.enemies[0].hp
	app.animate_combat_action(0, 0)
	check(app.game.run.combat.enemies[0].hp == hp, "duplicate input ignored")
	check(Game.new(SAVE, true).run == app.game.run, "action committed before animation completes")
	await create_timer(0.26).timeout
	await shot("attack")
	await settled()
	check(not app.combat_busy and app.hero_art[0].sprite.animation == "idle", "returns to idle")
	app.game.run.combat.energy = 3
	app.game.run.combat.hand = [{"id": "guardian_bash", "upgraded": false}]
	app.continue_run()
	app.animate_combat_action(0, 0)
	check(app.hero_art[0].sprite.animation == "bash", "shield bash uses bash animation")
	await create_timer(0.36).timeout
	await shot("bash")
	await settled()
	for card_id in ["guardian_guard", "guardian_wall", "guardian_echo"]:
		app.game.run.combat.energy = 3
		app.game.run.combat.hand = [{"id": card_id, "upgraded": false}]
		app.continue_run()
		app.animate_combat_action(0, 0)
		check(app.hero_art[0].sprite.animation == "guard", card_id + " uses shield defense")
		await create_timer(0.25).timeout
		await shot("guard")
		await settled()
	app.game.run.heroes[0].block = 0
	app.game.run.combat.enemies[0].intent = {"damage": 8, "target": 0}
	app.animate_combat_action()
	await reaction("hurt")
	check(app.hero_art[0].sprite.animation == "hurt", "enemy damage triggers hurt")
	await create_timer(0.1).timeout
	await shot("hurt")
	await settled()
	app.game.run.heroes[0].hp = 1
	app.game.run.combat.enemies[0].intent = {"damage": 8, "target": 0}
	app.continue_run()
	app.animate_combat_action()
	await reaction("death")
	check(app.hero_art[0].sprite.animation == "death", "lethal hit triggers death")
	await settled()
	check(app.hero_art[0].fallen and app.hero_art[0].sprite.frame == 5 and not app.hero_art[0].sprite.is_playing(), "corpse persists while companion plays")
	await shot("fallen")
	app.game.run.combat.enemies[0].hp = 1
	app.game.run.combat.energy = 3
	app.game.run.combat.hand = [{"id": "cleric_light", "upgraded": false}]
	app.continue_run()
	app.animate_combat_action(0, 0)
	while app.combat_busy and app.hero_art[0].sprite.animation != "revive":
		await process_frame
	check(app.hero_art[0].sprite.animation == "revive", "survivor victory triggers recovery")
	await create_timer(0.3).timeout
	await shot("revive")
	await settled()
	check(app.screen == "reward" and app.game.run.heroes[0].hp == 16, "recovery preserves 25 percent rule")
	app.game.new_run(["guardian", "cleric"], 1)
	app.game.enter_node(0)
	app.game.run.heroes[0].hp = 1
	app.game.run.heroes[1].hp = 1
	app.game.run.combat.enemies[0].intent = {"damage": 90, "target": 0, "all": true}
	app.continue_run()
	await app.animate_combat_action()
	check(app.screen == "defeat" and not app.combat_busy, "defeat waits for fall without blocking result")
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(SAVE + suffix)
	print("GUARDIAN CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)

func reaction(expected: String) -> void:
	var deadline = Time.get_ticks_msec() + 3000
	while app.combat_busy and app.hero_art[0].sprite.animation != expected and Time.get_ticks_msec() < deadline:
		await process_frame
