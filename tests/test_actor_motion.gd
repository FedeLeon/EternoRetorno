extends SceneTree
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr(message)
func shot(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("motion/" + name + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var ui = load("res://main.tscn").instantiate()
	ui.game = preload("res://src/game.gd").new("user://unused-motion.save", false)
	root.add_child(ui)
	ui.game.new_run(["warrior", "guardian"], 42)
	ui.game.enter_node(0)
	ui.continue_run()
	for child in ui.layer.get_children():
		ui.layer.remove_child(child)
		child.queue_free()
	var actors = []
	var index = 0
	for hero in ui.game.content.heroes:
		var actor = ui.art(hero, 20 + index * 205, 120, 170, 160, ui.layer, {"weapon":3,"armor":3})
		actors.append(actor)
		index += 1
	await create_timer(0.2).timeout
	var positions = actors.map(func(a): return a.sprite.position)
	await shot("idle-a")
	await create_timer(0.7).timeout
	await shot("idle-b")
	for i in range(actors.size()):
		var actor = actors[i]
		check(actor.sprite.frame == 0 and not actor.sprite.is_playing(), "stable idle frame")
		check(actor.sprite.position == positions[i], "no body translation")
		check(actor.sprite.material.get_shader_parameter("enabled") == 1.0, "idle detail motion active")
	await actors[0].play_once("attack")
	await process_frame
	check(actors[0].sprite.frame == 0, "attack returns to stable idle")
	var enemy = preload("res://src/enemy_sprite.gd").new()
	enemy.visual_id = "crypt_lancer"
	ui.rect(enemy, 500, 390, 200, 220)
	enemy.play_once("death")
	await create_timer(0.55).timeout
	check(enemy.sprite.material != null and enemy.acting, "ashes mid-animation")
	await shot("enemy-ash")
	await create_timer(0.85).timeout
	check(enemy.fallen and not enemy.sprite.visible and not enemy.acting, "enemy disappears after ashes")
	print("ACTOR MOTION FAILURES: ", failures)
	quit(1 if failures else 0)
