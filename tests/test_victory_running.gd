extends SceneTree
const Run = preload("res://src/presentation/hero_run.gd")
const Ground = preload("res://src/presentation/hero_grounding.gd")
const Flow = preload("res://src/ui/combat_flow.gd")
var checks = 0
var failures = 0
func _initialize(): call_deferred("verify")
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func geometry(actor: Control) -> Vector2:
	var sprite: AnimatedSprite2D = actor.sprite
	var texture = sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame)
	var image = texture.get_image()
	if image.is_compressed(): image.decompress()
	var top = image.get_height()
	var bottom = Ground.bottom(texture)
	for y in range(image.get_height()):
		var found = false
		for x in range(image.get_width()):
			if image.get_pixel(x,y).a > 0.5:
				top = y; found = true; break
		if found: break
	var foot = sprite.global_transform * Vector2(0,bottom+sprite.offset.y)
	return Vector2(foot.y,(bottom-top)*sprite.global_transform.y.length())
func verify():
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://victory-running",false)
	root.add_child(app)
	for pair in [["warrior","guardian"],["rogue","mage"]]:
		app.game.profile.settings = {"combat_speed":1.0,"reduce_cutins":true}
		app.apply_options()
		app.game.new_run(pair,31)
		app.game.enter_node(0)
		app.game._start_combat(["rat"])
		app.continue_run()
		await process_frame
		# Check every frame, including transition from an offset guard gesture.
		for actor in app.hero_art.values():
			var idle = geometry(actor)
			var outer = actor.scale
			actor.idle_motion.advance(3.4)
			Run.start(actor)
			actor.sprite.pause()
			for frame in range(12):
				actor.sprite.frame = frame
				var pose = geometry(actor)
				check(absf(pose.x-idle.x)<0.1,"feet remain on idle ground " + actor.hero_id + str(frame))
				check(pose.y/idle.y>=0.94 and pose.y/idle.y<=1.06,"running keeps hero size " + actor.hero_id + str(frame))
				check(actor.scale==outer,"parent scale remains fixed")
			Run.stop(actor)
			check(geometry(actor).is_equal_approx(idle),"stop restores idle geometry")
		# Actual final blow must leave both heroes travelling horizontally.
		app.game.run.combat.enemies[0].hp = 1
		app.game.run.combat.hand = [{"id":"warrior_slash" if pair[0]=="warrior" else "rogue_cut","upgraded":false}]
		app.game.run.combat.energy = 10
		app.continue_run()
		await process_frame
		var actors = app.hero_art.values()
		var initial = [geometry(actors[0]),geometry(actors[1])]
		Flow.run(app,0,0)
		var committed = app.game.run.duplicate(true)
		var seen = [false,false]
		var captured = false
		var started_running = -1
		while app.combat_busy:
			for i in range(actors.size()):
				var actor: Control = actors[i]
				if is_instance_valid(actor) and actor.sprite.animation=="run":
					if not seen[i]:
						seen[i] = true
						check(absf(geometry(actor).x-initial[i].x)<0.1,"victory preserves ground " + pair[i])
					check(absf(geometry(actor).x-initial[i].x)<0.1,"horizontal departure " + pair[i])
					var ratio = geometry(actor).y/initial[i].y
					check(ratio>=0.94 and ratio<=1.06,"departure keeps hero size " + pair[i])
			if seen[0] and seen[1] and started_running<0: started_running = Time.get_ticks_msec()
			if started_running>=0 and Time.get_ticks_msec()-started_running>400 and not captured:
				captured = true
				if DisplayServer.get_name()!="headless":
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("victory-running/"+pair[0]+".png"))
			await create_timer(0.1).timeout
		check(seen==[true,true],"both heroes run after victory")
		check(app.game.run==committed,"departure cannot change resolved battle")
	app.queue_free()
	await process_frame
	print("VICTORY RUNNING: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
