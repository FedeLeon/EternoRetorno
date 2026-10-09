extends SceneTree
const Game = preload("res://src/game.gd")
const Dungeon = preload("res://src/dungeon.gd")
const Preferences = preload("res://src/presentation/preferences.gd")
var checks = 0
var failures = 0
var app: Control
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",text)
func capture(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("whole-game/"+id+".png"))
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-whole-game-polish.save",false)
	app.game.profile.tutorial_complete = true
	root.add_child(app);await process_frame
	var additions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/polish_enemies.json"))
	check(additions.size() == 6,"six additional enemy definitions")
	for floor_number in [1,2,3]:
		var seen = {}
		var rng = RandomNumberGenerator.new()
		for seed_value in range(60):
			rng.seed = seed_value
			for room in Dungeon.create(rng,floor_number):
				if room.kind != "combat": continue
				for id in room.encounter: seen[id] = true
		for id in additions:
			if id in Dungeon.definition(floor_number).common:
				check(seen.has(id),"new enemy appears in random maps: "+id)
	app.game.new_run(["guardian","mage"],42)
	app.game.enter_node(0)
	for id in additions:
		app.game._start_combat([id]);app.continue_run();await process_frame
		var actor = app.enemy_art[0]
		check(actor.has_motion_frames,"new enemy has drawn animation: "+id)
		var texture = actor.sprite.texture.get_image()
		var source = Image.load_from_file("res://docs/whole_game_polish/normalized/%s_motion.png" % additions[id].visual)
		if source.get_width()%4 != 0 or source.get_height()%2 != 0:
			source.resize(ceili(source.get_width()/4.0)*4,ceili(source.get_height()/2.0)*2,Image.INTERPOLATE_NEAREST)
		var unique = {}
		for frame in range(8):
			unique[texture.get_region(Rect2i(frame*128,0,128,128)).get_data().hex_encode().sha256_text()] = true
			var cell_size = source.get_size()/Vector2i(4,2)
			var cell = source.get_region(Rect2i(Vector2i(frame%4,frame/4)*cell_size,cell_size))
			var bounds = preload("res://scripts/enemy_art_import.gd").opaque_bounds(cell)
			check(bounds.position.x>=8 and bounds.position.y>=8 and bounds.end.x<=cell_size.x-8 and bounds.end.y<=cell_size.y-8,"complete silhouette stays inside cell: %s / %d" % [id,frame])
		check(unique.size()==8,"eight different poses: "+id)
		var baseline = actor.sprite.position
		actor.play_once("attack");await create_timer(0.25).timeout
		check(actor.acting and actor.sprite.frame>=4,"windup and strike use drawn poses: "+id)
		await capture(id+"-attack")
		await create_timer(0.32).timeout
		check(not actor.acting and absf(actor.sprite.position.x-baseline.x)<0.01,"returns to actor position: "+id)
		var cut = preload("res://src/presentation/enemy_cut_in.gd").play(app.layer,additions[id].visual)
		check(cut != null and cut.from_right,"new transparent foreground attack: "+id)
		check(cut.picture.texture.get_image().get_pixel(0,0).a<0.05,"transparent cut-in corner: "+id)
		await create_timer(0.35).timeout;await capture(id+"-cutin");await cut.finished
	var game = Game.new("user://unused-enemy-hit-receipts.save",false)
	game.new_run(["guardian","mage"],42);game.enter_node(0)
	game._start_combat(["goblin_warrior","goblin_archer"])
	for hero in game.run.heroes: hero.block=10
	game.run.combat.enemies[0].intent={"damage":6,"block":0,"target":0}
	game.run.combat.enemies[1].intent={"damage":7,"block":0,"all":true,"target":0}
	var hp = game.run.heroes[0].hp
	game.end_turn()
	check(game.resolved_enemy_hits[0][0].absorbed==6 and game.resolved_enemy_hits[0][0].lost==0,"fully blocked first receipt")
	check(game.resolved_enemy_hits[1][0].absorbed==4 and game.resolved_enemy_hits[1][0].lost==3 and game.resolved_enemy_hits[1][0].hp==hp-3,"second receipt preserves intermediate guard and life")
	check(game.resolved_enemy_hits[1].size()==2 and game.resolved_enemy_hits[1][1].owner==1,"area hit includes both actual targets")
	check(not game.run.has("resolved_enemy_hits"),"receipts remain transient, outside save state")
	for enemy in game.run.combat.enemies: enemy.intent={"damage":0,"block":3,"target":0}
	game.end_turn();check(game.resolved_enemy_hits.is_empty(),"new end turn clears old hit receipts")
	app.game._start_combat(["goblin_warrior","goblin_archer"])
	app.game.run.combat.enemies[0].intent={"damage":4,"block":0,"target":0}
	app.game.run.combat.enemies[1].intent={"damage":5,"block":0,"target":1}
	Preferences.settings.impact_strength=0.0
	app.continue_run();await process_frame
	Preferences.settings.impact_strength=0.0
	preload("res://src/ui/combat_flow.gd").run(app)
	var committed = app.game.run.duplicate(true)
	var numbers = false
	while app.combat_busy:
		var showing = app.layer.get_children().any(func(node):return node.name.begins_with("FloatingDamage"))
		if showing and not numbers: await capture("enemy-impact")
		numbers = numbers or showing
		await process_frame
	check(numbers,"enemy hits show numbers even with shake disabled")
	check(app.game.run==committed,"playback does not resolve or mutate committed adventure")
	app.game.run.phase="map";app.screen="map";app.render();await process_frame
	var flows = app.layer.find_children("AvailableRouteFlow*","",true,false)
	check(flows.size()==app.game.run.nodes[app.game.run.current].next.size(),"each available path has a moving route marker")
	await capture("available-paths")
	app.game.profile.bestiary={"crypt_tomb_raider":{"encounters":1,"kills":0},"forest_alpha_bat":{"encounters":2,"kills":1},"ash_warlord":{"encounters":1,"kills":0}}
	var profile = app.game.profile.duplicate(true)
	app.return_screen="home";app.screen="bestiary";app.render();await process_frame
	var body = app.layer.find_child("BestiaryEntries",true,false)
	check(body.get_child_count()==3,"bestiary initially shows discovered entries")
	app.layer.get_node("BestiaryFloor2").pressed.emit();await process_frame
	check(body.get_child_count()==1 and body.get_child(0).name=="BestiaryEntry_forest_alpha_bat","filter by actual dungeon membership")
	app.layer.get_node("BestiarySearch").text="señor"
	app.layer.get_node("BestiarySearch").text_changed.emit("señor");await process_frame
	check(body.get_child(0).name=="BestiaryEmpty","empty search has explanation")
	app.layer.get_node("BestiaryFloor3").pressed.emit();await process_frame
	check(body.get_child_count()==1 and body.get_child(0).name=="BestiaryEntry_ash_warlord","search combines with dungeon filter")
	await capture("bestiary-filtered")
	app.layer.get_node("BestiaryFloor1").pressed.emit()
	app.layer.get_node("BestiarySearch").text="serpiente"
	app.layer.get_node("BestiarySearch").text_changed.emit("serpiente")
	app.layer.get_node("BestiaryKnownOnly").button_pressed=false
	await process_frame
	check(body.get_child(0).name=="BestiaryEmpty","search never reveals undiscovered names")
	check(app.game.profile==profile,"bestiary inspection does not change profile")
	check(app.audio.current_context=="title","home bestiary preserves title music")
	app.screen="options";app.render();await process_frame
	app.layer.get_node("MusicVolume").value=43
	check(app.layer.get_node("MusicVolumeValue").text=="43 %","volume displays actual percentage")
	await capture("options-values")
	app.audio.apply_settings({"music_volume":0.75,"sfx_volume":0.85,"volume":1.0})
	var random_state = app.game.rng.state
	var previous = ""
	for i in range(12):
		app.audio.play_sfx("blade")
		check(app.audio.last_variant.blade != previous,"successive sword sounds alternate samples")
		previous=app.audio.last_variant.blade
	check(app.game.rng.state==random_state,"audio variations never consume adventure RNG")
	var recording: AudioEffectRecord
	if DisplayServer.get_name() != "headless":
		recording = AudioEffectRecord.new()
		AudioServer.add_bus_effect(0,recording)
		recording.set_recording_active(true)
	for floor_number in [2,3]:
		var run={"floor":floor_number}
		var combat = preload("res://src/audio/screen_audio.gd").context("combat",run)
		var reward = preload("res://src/audio/screen_audio.gd").context("reward",run)
		app.audio.set_context(combat);var player=app.audio.music
		check(player.playing and player.stream.get_length()>100,"dungeon arrangement playable")
		if recording != null: await create_timer(1.0).timeout
		app.audio.set_context(reward)
		check(app.audio.music==player,"reward softens same music without restarting")
		if recording != null: await create_timer(0.8).timeout
	if recording != null:
		recording.set_recording_active(false)
		recording.get_recording().save_to_wav(preload("res://tests/artifacts.gd").path("whole-game/dungeon-mix.wav"))
		AudioServer.remove_bus_effect(0,AudioServer.get_bus_effect_count(0)-1)
	Preferences.settings.low_effects=true
	var dummy = Control.new();root.add_child(dummy)
	check(preload("res://src/presentation/support_feedback.gd").play(app.layer,dummy,"heal")==null,"support particles honor low effects")
	dummy.queue_free()
	app.apply_options()
	app.queue_free();await process_frame
	print("WHOLE GAME POLISH: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
