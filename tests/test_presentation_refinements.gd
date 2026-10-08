extends SceneTree
const Game = preload("res://src/game.gd")
const HeroCutIn = preload("res://src/presentation/hero_cut_in.gd")
const Geometry = preload("res://src/map_geometry.gd")
var checks = 0
var failures = 0
var app: Control
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",message)
func capture(id: String) -> void:
	await process_frame
	await create_timer(0.18).timeout
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("film-review/"+id+".png"))
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://presentation-refinements-isolated",false)
	app.game.profile.tutorial_complete = true
	root.add_child(app)
	await process_frame
	for hero in app.game.content.heroes:
		for action in ["attack","defense"]:
			var effect = HeroCutIn.play(app.layer,hero,action)
			check(is_equal_approx(effect.duration,0.96),"slower foreground "+hero+" "+action)
			effect.set_process(false)
			var finished = [0]
			effect.finished.connect(func(): finished[0]+=1)
			for frame in range(16): effect._process(0.25)
			check(effect.frame_index == 15 and finished[0] == 1,"all frames finish once "+hero+" "+action)
			await process_frame
	var shared = preload("res://src/presentation/comic_cut_in.gd").new()
	check(is_equal_approx(shared.duration,0.72),"enemy default duration unchanged")
	shared.free()
	app.game.profile.buildings = {}
	var profile_before = app.game.profile.duplicate(true)
	app.screen = "base_camp"; app.render()
	check(app.layer.has_node("ProjectsBuilding") and app.layer.has_node("ProjectsEntrance"),"permanent projects workshop without construction")
	check(not app.layer.get_children().any(func(node):return node is Button and node.text == "Bestiario"),"no camp bestiary access")
	var training = app.layer.get_node("TrainingEntrance")
	check(training.icon != null and training.size.x == training.size.y and training.text == "","square illustrated training button")
	await capture("camp-unbuilt")
	app.layer.get_node("ProjectsEntrance").pressed.emit()
	check(app.screen == "projects" and app.game.profile == profile_before,"workshop opens without cost or profile mutation")
	app.game.profile.buildings = {"market":true,"forge":true,"church":true,"expeditions":true}
	app.screen = "base_camp"; app.render(); await capture("camp-built")
	app.screen = "home"; app.render()
	check(app.layer.has_node("HomeBestiary"),"bestiary remains at home")
	for floor_number in [1,2,3]:
		app.game.new_run(["warrior","cleric"],141,{},floor_number)
		app.screen = "map"; app.render(); await capture("map-clean-%d" % floor_number)
	# Presentation upgrade of a saved spiral does not rewrite rooms or links.
	for node in app.game.run.nodes:
		node.erase("layout_version")
		node.position = [Geometry.LEGACY_CENTERS[node.stage].x,Geometry.LEGACY_CENTERS[node.stage].y]
	var saved_map = app.game.run.duplicate(true)
	app.render(); await capture("map-legacy-presentation")
	check(app.game.run == saved_map,"legacy map positions and paths remain saved exactly")
	var clips = preload("res://src/ui/cinematic_navigation.gd").catalog()
	var image_hashes: Dictionary = {}
	for id in clips:
		var player = preload("res://src/presentation/cinematic_player.gd").new()
		player.definition = clips[id]; app.add_child(player)
		await process_frame
		for chapter in range(clips[id].chapters.size()):
			var shot: Dictionary = clips[id].chapters[chapter]
			check(ResourceLoader.exists(shot.image),"cinematic chapter asset "+id+str(chapter))
			var hash = FileAccess.get_sha256(shot.image)
			check(not image_hashes.has(hash),"unique story composition "+id+str(chapter))
			image_hashes[hash] = true
			check(player.backdrop.texture.resource_path == shot.image,"chapter changes actual displayed texture")
			check(not player.has_node("HeroPortrait"),"story shot replaces static portrait overlay")
			if chapter > 0:
				check(player.has_node("ChapterDissolve"),"chapter crossfade created")
				player.toggle_pause(); var alpha: float = player.transition.modulate.a
				await create_timer(0.08).timeout
				check(is_equal_approx(alpha,player.transition.modulate.a),"pause freezes crossfade")
				player.toggle_pause()
			await capture("shot-"+id+"-"+str(chapter))
			player.advance()
		await process_frame
	check(image_hashes.size() == 21,"twenty-one distinct cinematic frames")
	var sound_events: Array = []
	app.audio.sound_played.connect(func(id): sound_events.append(id))
	preload("res://src/presentation/preferences.gd").settings = {"impact_strength":0.0}
	var target = Control.new(); app.layer.add_child(target)
	var impact = preload("res://src/presentation/impact_feedback.gd")
	var recording: AudioEffectRecord
	var recording_bus = 0 # Capture final output after the existing master limiter.
	if DisplayServer.get_name() != "headless":
		for channel in app.audio.get_children():
			if channel is AudioStreamPlayer: channel.stop()
		recording = AudioEffectRecord.new()
		AudioServer.add_bus_effect(recording_bus,recording)
		recording.set_recording_active(true)
	impact.play(app,target,{"absorbed":5,"lost":0})
	impact.play(app,target,{"absorbed":3,"lost":4})
	impact.play(app,target,{"absorbed":0,"lost":4})
	check(sound_events == ["shield_impact","shield_impact","flesh_impact"],"full and partial absorption sound metallic; unblocked damage uses flesh")
	check(app.audio.catalog.events.shield_impact.files == ["metal_clash","metal_clash_2"],"two dedicated metallic impact variants")
	for id in ["metal_clash","metal_clash_2"]:
		var stream = app.audio.stream(id)
		check(stream != null and stream.get_length()>0.1,"metal impact playable "+id)
	if recording != null:
		await create_timer(1.0).timeout
		recording.set_recording_active(false)
		var clip = recording.get_recording()
		check(clip != null and not clip.data.is_empty(),"blocked attacks produce native mixer output")
		clip.save_to_wav(preload("res://tests/artifacts.gd").path("film-review/metal-impact.wav"))
		AudioServer.remove_bus_effect(recording_bus,AudioServer.get_bus_effect_count(recording_bus)-1)
	app.queue_free(); await process_frame
	await create_timer(0.15).timeout
	print("PRESENTATION REFINEMENTS: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
