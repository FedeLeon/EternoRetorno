extends SceneTree
## Replays actual multi-hit counters, not just isolated attack poses.
const Flow = preload("res://src/ui/combat_flow.gd")
var checks = 0
var failures = 0
func _initialize(): call_deferred("verify")
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func verify():
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://counter-size-test",false)
	root.add_child(app)
	for id in ["ash_cinder_wolf", "ash_warlord", "forest_alpha_bat", "forest_dark_raven"]:
		app.game.profile.settings = {"combat_speed":1.0,"reduce_cutins":true}
		app.apply_options()
		app.game.new_run(["warrior","guardian"],31)
		app.game.enter_node(0)
		app.game._start_combat([id])
		var enemy = app.game.run.combat.enemies[0]
		enemy.hp = 500; enemy.max_hp = 500; enemy.intent.counter = 4
		app.game.run.combat.hand = [{"id":"warrior_onslaught","upgraded":false}]
		app.game.run.combat.energy = 10
		app.continue_run()
		await process_frame
		var actor: Control = app.enemy_art[0]
		var scale_before = actor.scale
		var heights: Array = []
		var atlas = actor.sprite.texture.get_image()
		for frame in range(8): heights.append(opaque_height(atlas, frame))
		var idle_height = float(heights[0]) * actor.sprite.scale.y
		var contacts = [0]
		actor.sprite.frame_changed.connect(func():
			var frame: int = actor.sprite.frame
			check(actor.scale == scale_before,"outer size stays fixed: " + id)
			check(float(heights[frame])*actor.sprite.scale.y >= idle_height*0.8,
				"counter silhouette stays full size: %s frame=%d" % [id,frame])
			if frame == 6: contacts[0] += 1
		)
		Flow.run(app,0,0)
		check(app.combat_busy,"combo accepted " + id)
		check(app.game.resolved_card_hits.filter(func(event): return event.kind == "counter").size() == 3,"three committed counters " + id)
		var committed = app.game.run.duplicate(true)
		var captured = false
		while app.combat_busy:
			if is_instance_valid(actor) and actor.sprite.frame == 6 and not captured:
				captured = true
				if DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("enemy-counter/"+id+".png"))
			await process_frame
		check(contacts[0] == 3,"three complete counter animations " + id)
		check(app.game.run == committed,"playback preserves committed damage/save " + id)
		check(app.enemy_art[0].sprite.frame < 4 and app.enemy_art[0].scale == scale_before,"normal size after counters " + id)
	app.queue_free()
	await process_frame
	print("ENEMY COUNTER SIZE: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
func opaque_height(atlas: Image, frame: int) -> int:
	var cell = atlas.get_height()
	var top = cell
	var bottom = 0
	for y in range(cell):
		for x in range(frame*cell,(frame+1)*cell):
			if atlas.get_pixel(x,y).a >= 0.5:
				top = mini(top,y); bottom = maxi(bottom,y+1)
	return bottom-top
