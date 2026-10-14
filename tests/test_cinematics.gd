extends SceneTree
const Navigation = preload("res://src/ui/cinematic_navigation.gd")
const Player = preload("res://src/presentation/cinematic_player.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures+=1;printerr("FAIL: ",message)
func capture(name: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("integral-review/"+name+".png"))
func run_tests() -> void:
	root.size=Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://cinematics-test.json",false)
	root.add_child(app)
	await process_frame
	var clips = Navigation.catalog()
	check(clips.size()==8,"intro, four hero stories and three boss finales")
	var original = app.game.run.duplicate(true)
	var profile = app.game.profile.duplicate(true)
	for id in clips:
		check(ResourceLoader.exists("res://assets/cinematics/%s.png"%clips[id].background),"background exists "+id)
		Navigation.play(app,id)
		await process_frame
		var player = app.get_node("CinematicPlayer")
		check(app.combat_busy and app.has_meta("cinematic_active"),"underlying navigation blocked")
		var chapter_before = player.chapter
		player.get_node("PauseCinematic").pressed.emit()
		var seconds: float = player.elapsed
		await create_timer(0.05).timeout
		check(player.paused and is_equal_approx(player.elapsed,seconds),"pause freezes chapter")
		player.get_node("PauseCinematic").pressed.emit()
		await create_timer(0.42).timeout
		await capture("cinema-"+id)
		player.get_node("NextCinematic").pressed.emit()
		check(player.chapter==chapter_before+1,"continue advances exactly one chapter")
		player.get_node("SkipCinematic").pressed.emit()
		await process_frame
		check(not app.combat_busy and not app.has_meta("cinematic_active"),"skip restores interaction")
		check(app.audio.current_context=="title","skip restores audio context")
		check(app.game.run==original and app.game.profile==profile,"presentation never mutates game "+id)
	Navigation.enter(app)
	await process_frame
	check(app.has_node("CinematicPlayer"),"first start opens intro")
	app.get_node("CinematicPlayer").finish()
	await process_frame
	check(app.screen=="base_camp" and app.game.profile.cinematics_seen.has("intro"),"intro resumes camp and persists discovery")
	Navigation.enter(app)
	check(not app.has_node("CinematicPlayer"),"intro not repeated automatically")
	app.game.new_run(["warrior","guardian"],123,{},1)
	Navigation.party(app)
	for hero in ["warrior","guardian"]:
		await process_frame
		check(app.has_node("CinematicPlayer"),"new party shows story "+hero)
		app.get_node("CinematicPlayer").finish()
	await process_frame
	check(app.game.profile.cinematics_seen.has("hero_warrior") and app.game.profile.cinematics_seen.has("hero_guardian"),"hero discovery remembered")
	for floor_number in [1,2,3]:
		app.game.new_run(["warrior","guardian"],123,{},floor_number)
		var boss_index: int = app.game.run.nodes.size()-1
		app.game.run.current=boss_index
		check(app.game.run.nodes[boss_index].kind=="boss","fixture boss is last room")
		app.game.run.phase="reward"
		app.game.run.reward=[{"id":"warrior_slash","upgraded":false}]
		app.game.run.boss_defeated=true
		var deck: Array = app.game.run.deck.duplicate(true)
		var souls: int = app.game.profile.souls
		if floor_number == 1: app.continue_run()
		else: Navigation.boss(app)
		await process_frame
		check(app.has_node("CinematicPlayer"),"boss opens finale")
		check("boss_%d"%floor_number in app.game.run.cinematics_seen,"boss marked before playback")
		app.get_node("CinematicPlayer").finish()
		await process_frame
		Navigation.boss(app)
		check(not app.has_node("CinematicPlayer"),"boss never replays on resume")
		check(app.game.run.deck==deck and app.game.profile.souls==souls and app.game.run.phase=="reward","no duplicate awards or lost reward")
	app.screen="cinematics";app.render()
	await process_frame
	await capture("cinema-gallery")
	check(app.layer.get_children().size()>10,"gallery composed")
	app.layer.find_child("ViewCinematic_hero_guardian",true,false).pressed.emit()
	await process_frame
	check(app.has_node("CinematicPlayer"),"gallery replays a character story")
	app.get_node("CinematicPlayer").finish()
	await process_frame
	check(app.game.profile.cinematics_seen.has("hero_guardian"),"viewing in gallery also counts as seen")
	check(app.game.store.write(app.game.profile,app.game.run),"write isolated cutscene save")
	var restored = preload("res://src/game.gd").new("user://cinematics-test.json",true)
	check(restored.profile.get("cinematics_seen",{}).has("boss_3"),"new watched flags survive save/load")
	app.game.profile.settings = {"auto_cinematics":false}
	app.game.run.cinematics_seen=[]
	Navigation.boss(app)
	check(not app.has_node("CinematicPlayer") and "boss_3" in app.game.run.cinematics_seen,"automatic cutscenes can be disabled without losing discovery")
	app.queue_free();await process_frame
	print("CINEMATICS: %d checks / %d failures"%[checks,failures])
	quit(1 if failures else 0)
