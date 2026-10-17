extends SceneTree
const Actor = preload("res://src/presentation/detailed_hero.gd")
const Grounding = preload("res://src/presentation/hero_grounding.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var scene = Control.new()
	root.add_child(scene)
	var background = ColorRect.new()
	background.size = Vector2(1280, 720)
	background.color = Color("1a2331")
	scene.add_child(background)
	var actors: Array = []
	for hero in ["warrior", "guardian", "rogue", "mage"]:
		var actor = Actor.new()
		actor.hero_id = hero
		actor.position = Vector2(40 + actors.size() * 310, 190)
		actor.size = Vector2(240, 210)
		scene.add_child(actor)
		actor.set_process(false)
		preload("res://src/ui/components/combat_actor_scale.gd").hero(actor, hero)
		actors.append(actor)
	for actor in actors:
		var signatures = {}
		for frame in range(24):
			var image = actor.sprite.sprite_frames.get_frame_texture("idle", frame).get_image()
			signatures[hash(image.get_data())] = true
		check(signatures.size() == 24, "twenty-four genuinely different authored guard poses")
	var first_frames: Array = []
	for actor in actors:
		actor.idle_motion.advance(0.1)
		check(actor.sprite.frame == 0, "initial guard begins at neutral")
		first_frames.append(actor.idle_motion.wait_remaining)
	check(first_frames[0] != first_frames[1], "heroes begin at different phases")
	await shot("rest")
	var seen: Dictionary = {}
	for step in range(110):
		for actor in actors:
			var old_scale = actor.sprite.scale
			var old_position = actor.sprite.position
			actor.idle_motion.advance(0.1)
			if actor.sprite.frame > 0: seen[actor.hero_id] = true
			check(actor.sprite.frame >= 0 and actor.sprite.frame < 24, "guard uses authored in-betweens")
			var texture = actor.sprite.sprite_frames.get_frame_texture("idle", actor.sprite.frame)
			var base = actor.sprite.sprite_frames.get_frame_texture("idle", 0)
			check(Grounding.bottom(texture) + actor.sprite.offset.y == Grounding.bottom(base), "feet stay at same ground line")
			check(actor.sprite.scale == old_scale and actor.sprite.position == old_position, "guard never scales or translates actor")
		if DisplayServer.get_name() != "headless": await create_timer(0.1).timeout
		if step == 43: await shot("guard")
	check(seen.size() == 4, "all four heroes play their authored guard drawings")
	for actor in actors:
		check(actor.idle_motion.cycles >= 1, "continuous guard completes breathing cycles")
		check(actor.get_children().filter(func(n): return n is Sprite2D).is_empty(), "idle creates no ghost copies")
		actor.play_once("attack")
		actor.idle_motion.advance(0.3)
		check(actor.sprite.animation == "attack" and not actor.idle_motion.moving, "attack interrupts idle without being overwritten")
		actor.play_once("run")
		actor.idle_motion.advance(3)
		check(actor.sprite.animation == "run" and actor.sprite.is_playing(), "running remains uninterrupted")
		actor.set_fallen(true)
		actor.idle_motion.advance(10)
		check(actor.sprite.animation == "death" and actor.sprite.frame == 11 and not actor.idle_motion.moving, "fallen hero never gestures")
		actor.set_fallen(false)
		check(actor.sprite.frame == 0 and actor.idle_motion.wait_remaining > 0, "revive restores neutral guard before breathing")
	scene.queue_free()
	await process_frame
	await process_frame
	Actor.cache.clear()
	print("HERO GUARD IDLE: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
func shot(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("guard_idle/" + id + ".png"))
