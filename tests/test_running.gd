extends SceneTree
const Run = preload("res://src/presentation/hero_run.gd")
const Gear = preload("res://src/presentation/hero_equipment.gd")
var failures = 0
var checks = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr(message)
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	var host = Control.new()
	root.add_child(host)
	var background = TextureRect.new()
	background.texture = preload("res://assets/dungeon/combat.png")
	background.size = Vector2(1280,720)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	host.add_child(background)
	var art:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://docs/art_direction/postapocalyptic/assets.json"))
	var actors: Array = []
	var index = 0
	for hero in Run.HEIGHTS:
		var actor = load("res://src/%s_sprite.gd" % hero).new()
		actor.size = Vector2(170,160)
		actor.position = Vector2(25 + index*205, 260)
		host.add_child(actor)
		var frames = actor.sprite.sprite_frames
		check(frames.get_frame_count("run") == 8 and frames.get_animation_loop("run"), "eight looping frames " + hero)
		var hashes: Array = []
		for i in range(8):
			var texture = frames.get_frame_texture("run", i)
			var image = texture.atlas.get_image().get_region(texture.region)
			check(image.get_size() == Vector2i(128,128) and not image.is_invisible(), "full frame " + hero)
			check(image.get_pixel(0,0).a == 0 and image.get_used_rect().end.y <= 121, "transparent/grounded frame " + hero)
			var hash = hash(image.get_data())
			if hash not in hashes: hashes.append(hash)
		var authored = 8 if art.get("assets/heroes/running/%s.png"%hero,{}).get("comic_rebuild_revision",0)==1 else 6
		check(hashes.size() == authored, "distinct authored gait phases in eight timing frames " + hero)
		Gear.apply(actor, hero, {"weapon":3,"armor":3})
		check(actor.sprite.sprite_frames.get_frame_texture("run", 7).atlas.resource_path.contains("running"), "gear preserves separate running atlas")
		preload("res://src/ui/components/combat_actor_scale.gd").hero(actor, hero)
		var old_scale = actor.sprite.scale
		Run.start(actor)
		await create_timer(0.13).timeout
		check(actor.sprite.animation == "run" and actor.sprite.frame > 0, "run advances " + hero)
		check(actor.sprite.material.get_shader_parameter("enabled") == 0, "idle shader disabled while running")
		Run.stop(actor)
		check(actor.sprite.scale == old_scale and actor.sprite.animation == "idle", "stop restores gear scale")
		Run.start(actor)
		actors.append(actor)
		index += 1
	for frame in range(8):
		for actor in actors:
			actor.sprite.pause()
			actor.sprite.frame = frame
		await process_frame
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("running/frame-%d.png" % frame))
	for actor in actors:
		Run.stop(actor)
	var start_time = Time.get_ticks_msec()
	await preload("res://src/presentation/combat_effects.gd").leave_room(host, actors)
	check(Time.get_ticks_msec()-start_time >= 2400, "preserves slower departure")
	for actor in actors:
		check(actor.global_position.x >= 1459 and actor.sprite.animation == "run", "runs completely out of view")
	print("RUNNING CHECKS: ", checks, " | FAILURES: ", failures)
	quit(1 if failures else 0)
