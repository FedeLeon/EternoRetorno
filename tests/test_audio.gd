extends SceneTree
const Game = preload("res://src/game.gd")
const Routing = preload("res://src/audio/screen_audio.gd")
var checks = 0
var failures = 0
var played: Array[String] = []
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://audio-test.save", false)
	root.add_child(app)
	await process_frame
	var audio = app.audio
	audio.sound_played.connect(func(event): played.append(event))
	for id in audio.catalog.files:
		var sample = audio.stream(id)
		check(sample != null and sample.get_length() > 0, "playable resource " + id)
	check(audio.current_context == "title" and audio.music.playing, "title theme starts")
	var title_player = audio.music
	app.render()
	check(audio.music == title_player, "render preserves playing theme")
	app.open_base_camp()
	var camp_player = audio.music
	await process_frame
	for screen in ["market", "forge", "church", "refuge", "expeditions"]:
		audio.select_screen(screen, {})
		check(audio.music == camp_player, "camp music continues inside " + screen)
		check(audio.current_context == screen, "building soundscape " + screen)
	for i in range(30):
		audio.set_context("title" if i % 2 == 0 else "camp")
		await process_frame
	await create_timer(0.8).timeout
	check(audio.get_child_count() <= 16, "rapid navigation cleans outgoing channels")
	app.screen = "options"
	app.render()
	await process_frame
	app.layer.get_node("MusicVolume").value = 0
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")), "music mute independent")
	check(not AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "effects remain audible")
	app.layer.get_node("SfxVolume").value = 0
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Ambience")), "effects setting also mutes ambience")
	check(app.game.store.write(app.game.profile, app.game.run), "write settings to isolated save")
	var restored = Game.new("user://audio-test.save", true)
	check(restored.profile.settings.music_volume == 0 and restored.profile.settings.sfx_volume == 0, "new settings persist")
	app.set_option("music_volume", 0.75)
	app.set_option("sfx_volume", 0.85)
	var recording: AudioEffectRecord
	if DisplayServer.get_name() != "headless":
		recording = AudioEffectRecord.new()
		AudioServer.add_bus_effect(0, recording)
		recording.set_recording_active(true)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("audio/options.png"))
	var button = app.layer.get_node("Volume") # Sliders should not be connected as buttons.
	check(not button.has_meta("audio_bound"), "slider does not trigger button sounds")
	var test_button = app.button("Volver", 10, 10, 100, 40, func(): pass)
	await process_frame
	test_button.pressed.emit()
	check(played.has("back"), "shared button sound wired")
	var raw_button = Button.new()
	app.layer.add_child(raw_button)
	await process_frame
	raw_button.pressed.emit()
	check(played.has("click"), "standalone screen buttons wired")
	app.game.new_run(["warrior", "cleric"], 42)
	app.game.enter_node(0)
	app.continue_run()
	check(audio.current_context == "combat", "battle theme selected")
	var battle_player = audio.music
	app.layer.get_node("CombatHUD/Bag").pressed.emit()
	check(app.screen == "items" and audio.music == battle_player, "real bag navigation keeps battle theme")
	app.continue_run()
	check(Routing.context("deck", app.game.run, "combat") == "combat", "deck preserves battle audio")
	check(Routing.context("items", app.game.run, "combat") == "combat", "bag preserves battle audio")
	check(Routing.context("map", {"floor":2}) == "forest", "second dungeon soundscape")
	var battle = app.game.run.combat
	battle.enemies[0].hp = 100
	battle.enemies[0].max_hp = 100
	battle.enemies[0].intent = {"damage":0, "block":0, "target":0}
	# Use a known offensive card from the initial deck.
	var attack_id = app.game.run.deck.filter(func(c): return app.game.content.cards[c.id].owner == "warrior" and app.game.content.cards[c.id].damage > 0)[0].id
	battle.hand = [{"id":attack_id, "upgraded":false}]
	app.game.content.cards[attack_id].hits = 2
	battle.energy = 10
	app.render()
	played.clear()
	await process_frame
	await app.animate_combat_action(0, 0)
	check(played.count("blade") == 2, "one weapon sound per combo hit")
	check(played.has("card_use") and played.has("flesh_impact"), "card and impact sounds accompany committed action")
	battle = app.game.run.combat
	battle.enemies[0].intent = {"damage":2, "block":4, "target":0}
	app.render()
	played.clear()
	await app.animate_combat_action()
	check(played.has("ash") and played.has("block"), "discard and enemy block sound")
	check(played.has("bones") or played.has("monster") or played.has("goblin") or played.has("blade"), "enemy attack audio")
	if recording != null:
		recording.set_recording_active(false)
		var capture = recording.get_recording()
		check(capture != null and capture.data.size() > 0, "native mixer produces recorded output")
		capture.save_to_wav(preload("res://tests/artifacts.gd").path("audio/mix.wav"))
		AudioServer.remove_bus_effect(0, AudioServer.get_bus_effect_count(0) - 1)
	app.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("AUDIO: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
