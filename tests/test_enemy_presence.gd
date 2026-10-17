extends SceneTree
const Game = preload("res://src/game.gd")
const Enemy = preload("res://src/enemy_sprite.gd")
const Scale = preload("res://src/ui/components/combat_actor_scale.gd")
const Layout = preload("res://src/ui/components/combat_layout.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ", message)
func verify() -> void:
	root.size = Vector2i(1280, 720)
	var host = Control.new(); root.add_child(host)
	# Check every machine silhouette, including the wide drones and small sources.
	for id in Enemy.entries():
		var actor = Enemy.new(); actor.visual_id = id
		actor.position = Vector2(1002, 211); actor.size = Vector2(128, 132)
		host.add_child(actor); actor.set_process(false)
		Scale.enemy(actor); Scale.fit_enemy(actor, 245, 220)
		var bounds = Scale.silhouette(actor)
		var extent = bounds.size * actor.sprite.scale * actor.scale
		check(maxf(extent.x, extent.y) > Scale.HERO_HEIGHT * 0.98, "every machine has a substantial visual span: " + id)
		check(extent.x <= 220.01 and extent.y <= 245.01, "uniform fit preserves complete silhouette: " + id)
		check(is_equal_approx(actor.scale.x, actor.scale.y), "no stretched machine: " + id)
		var center = (actor.get_global_transform() * actor.sprite.position).x
		check(center - extent.x / 2 >= 535.99 and center + extent.x / 2 <= 1264.01, "wide machine stays in enemy arena: " + id)
		var scale_before = actor.scale
		Scale.fit_enemy(actor, 245, 220)
		check(actor.scale == scale_before, "repeat layout cannot progressively shrink machine: " + id)
		for frame in [0, 4, 6, 7]:
			actor.sprite.frame = frame
			check(actor.scale == scale_before, "animation leaves outer scale fixed: " + id)
		actor.queue_free(); await process_frame
	host.queue_free(); await process_frame
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-enemy-presence", false)
	root.add_child(app)
	var cases = [
		[1, ["boss"]], [2, ["goblin_warrior", "forest_wolf"]],
		[3, ["skeleton", "skeleton_shielder", "skeleton_mage"]],
		[1, ["rat", "rat", "rat"]]
	]
	for i in range(cases.size()):
		var item = cases[i]
		app.game.new_run(["warrior", "guardian"], 14, {}, item[0]); app.game.enter_node(0)
		app.game._start_combat(item[1])
		var before = app.game.run.duplicate(true); var rng = app.game.rng.state
		app.continue_run(); await process_frame
		check(app.game.run == before and app.game.rng.state == rng, "bigger actors do not change combat state or RNG")
		var ground = Layout.ground_for(app)
		check(ground >= 335, "normal formation moves lower")
		var occupied: Array[Rect2] = []
		for index in app.enemy_art:
			var actor: Control = app.enemy_art[index]
			var extent = Scale.silhouette(actor).size * actor.sprite.scale * actor.scale
			check(maxf(extent.x, extent.y) > Scale.HERO_HEIGHT * 0.98, "real formation retains imposing size")
			var bounds = Scale.silhouette(actor)
			var local_left = actor.sprite.position.x + (bounds.position.x - actor.sprite.texture.get_height() / 2.0) * actor.sprite.scale.x
			var left = (actor.get_global_transform() * Vector2(local_left, 0)).x
			var footprint = Rect2(left, 0, extent.x, 1)
			for previous in occupied:
				check(not previous.intersects(footprint), "idle silhouettes do not overlap horizontally")
			occupied.append(footprint)
			check(not app.enemy_health[index].z_as_relative and app.enemy_health[index].z_index > actor.z_index, "life stays legible above overlapping machine")
			var intent = app.layer.get_node("EnemyIntent%d" % index)
			check(intent.global_position.y > ground and intent.get_global_rect().end.y <= Layout.INFO_BOTTOM, "intent and effects follow feet without covering cards")
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("enemy_presence/formation_%d.png" % i))
	app.game._start_combat(["skeleton", "skeleton"])
	app.game.run.combat.enemies[1].rear = true
	app.render(); await process_frame
	check(app.enemy_art[0].scale == app.enemy_art[1].scale, "rear guard is no longer visually miniaturized")
	app.queue_free(); await process_frame
	print("ENEMY PRESENCE: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
