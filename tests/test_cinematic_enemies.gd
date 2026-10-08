extends SceneTree
const Game = preload("res://src/game.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1;printerr("FAIL: ",message)
func capture(name: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("integral-review/"+name+".png"))
func run_tests() -> void:
	root.size=Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game=Game.new("user://cinematic-enemies-test.json",false)
	app.game.profile.settings = {"tutorial_seen":true}
	root.add_child(app)
	app.game.new_run(["mage","ranger"],123,{},1)
	app.game.enter_node(0)
	var additions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/cinematic_enemies.json"))
	for id in additions:
		app.game._start_combat([id]);app.continue_run();await process_frame
		var actor = app.enemy_art[0]
		check(actor.has_motion_frames,"animated new enemy "+id)
		var pixels = actor.sprite.texture.get_image()
		var unique = {}
		for frame in range(8):unique[pixels.get_region(Rect2i(frame*128,0,128,128)).get_data().hex_encode().sha256_text()]=true
		check(unique.size()==8,"eight distinct drawn poses "+id)
		actor.play_once("attack")
		await create_timer(0.25).timeout
		check(actor.acting and actor.sprite.frame>=4,"attack poses played "+id)
		await capture("enemy-"+id+"-attack")
		await create_timer(0.25).timeout
		check(not actor.acting and actor.sprite.frame<4,"idle restored "+id)
		var cut = preload("res://src/presentation/enemy_cut_in.gd").play(app.layer,additions[id].visual)
		check(cut!=null and cut.from_right,"HD cut-in attacks left "+id)
		var image = cut.picture.texture.get_image()
		check(image.get_pixel(0,0).a<0.05,"alpha retained "+id)
		await create_timer(0.35).timeout
		await capture("enemy-"+id+"-cutin")
		await cut.finished
	var profile = app.game.profile.duplicate(true)
	var adventure = app.game.run.duplicate(true)
	for event in [{"absorbed":7,"lost":0,"damage":7},{"lost":19,"damage":19},{"lost":12,"damage":12,"pierce":true}]:
		var burst = preload("res://src/presentation/impact_burst.gd").play(app.layer,app.enemy_art[0],event)
		check(burst!=null,"impact burst appears")
		await create_timer(0.12).timeout
		await capture("impact-"+str(event.damage))
		await create_timer(0.42).timeout
		check(not is_instance_valid(burst),"particles cleaned up")
	check(app.game.run==adventure and app.game.profile==profile,"effects never mutate game")
	preload("res://src/presentation/preferences.gd").settings.low_effects=true
	check(preload("res://src/presentation/impact_burst.gd").play(app.layer,app.enemy_art[0],{"damage":20})==null,"reduced effects respected")
	app.apply_options()
	app.audio.apply_settings({"music_volume":0.5})
	var bus = AudioServer.get_bus_index("Music")
	var level = AudioServer.get_bus_volume_db(bus)
	app.audio.play_sfx("flesh_impact")
	check(is_equal_approx(AudioServer.get_bus_volume_db(bus),level-3),"impact gently ducks music")
	await create_timer(0.7).timeout
	check(is_equal_approx(AudioServer.get_bus_volume_db(bus),level),"music returns to user's level")
	for id in ["cinematic_intro","cinematic_return"]:check(app.audio.stream(id).get_length()>30,"cinematic arrangement playable")
	app.queue_free();await process_frame
	print("CINEMATIC ENEMIES / FX / MIX: %d checks / %d failures"%[checks,failures])
	quit(1 if failures else 0)
