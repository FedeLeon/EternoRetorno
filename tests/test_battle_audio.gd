extends SceneTree
const Game = preload("res://src/game.gd")
const Battle = preload("res://src/audio/battle_audio.gd")
var checks = 0
var failures = 0
var played: Array[String] = []
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func _initialize() -> void:
	call_deferred("run_tests")
func run_tests() -> void:
	var game = Game.new("user://unused-battle-audio", false)
	game.new_run(["warrior", "guardian"], 42)
	game.enter_node(0)
	var snapshot = game.run.duplicate(true)
	var state = game.rng.state
	var audio = preload("res://src/audio/audio_manager.gd").new()
	root.add_child(audio)
	audio.sound_played.connect(func(event): played.append(event))
	var sources: Dictionary = {}
	for id in game.content.enemies:
		for action in ["attack", "guard", "death"]:
			played.clear()
			Battle.enemy(audio,id,action)
			var event = "enemy_%s_%s" % [id,action]
			check(played == [event], "specific enemy action " + event)
			for file in audio.catalog.events[event].files:
				var stream = audio.stream(file)
				check(stream != null and stream.get_length() > 0.15 and stream.get_length() < 1.3, "short playable machine sound " + file)
				check(not sources.has(file), "each enemy action has own clip")
				sources[file] = true
	for id in ["warrior", "guardian", "rogue", "mage"]:
		for action in ["attack", "defense", "hurt"]:
			var event = "voice_%s_%s" % [id,action]
			check(audio.catalog.events[event].files.size() == 2, "voice variation " + event)
			for file in audio.catalog.events[event].files:
				check(audio.stream(file).get_length() > 0.15, "recorded human voice " + file)
		played.clear()
		Battle.hero(audio,id,"attack")
		check(played.has("voice_%s_attack" % id), "hero effort at attack")
		played.clear()
		Battle.hero(audio,id,"defense")
		check(played.has("voice_%s_defense" % id) and played.has("shield_impact"), "hero effort and metal at defense")
	played.clear()
	Battle.impact(audio,{"absorbed":4,"lost":0},"mage")
	check(played.has("shield_impact") and not played.has("flesh_impact"), "full guard sounds metallic")
	played.clear()
	Battle.impact(audio,{"absorbed":3,"lost":2},"rogue")
	check(played.has("shield_impact") and played.has("voice_rogue_hurt"), "partial guard has metal and human pain")
	played.clear()
	Battle.impact(audio,{"absorbed":0,"lost":4},"", "rat")
	check(played == ["machine_impact"], "machines have material impact, no flesh sound")
	played.clear()
	Battle.impact(audio,{"absorbed":0,"lost":0},"warrior")
	check(played.is_empty(), "zero damage has no contact or hurt sound")
	audio.last_played.clear()
	played.clear()
	audio.play_sfx("voice_warrior_attack")
	var first = audio.last_variant.voice_warrior_attack
	audio.play_sfx("voice_warrior_attack")
	check(played.size() == 1, "cooldown prevents overlapping identical voice events")
	audio.last_played.clear()
	audio.play_sfx("voice_warrior_attack")
	check(audio.last_variant.voice_warrior_attack != first, "voices do not immediately repeat same take")
	check(game.run == snapshot and game.rng.state == state, "all audio leaves combat and RNG untouched")
	audio.last_played.clear()
	Battle.hero(audio,"warrior","attack")
	Battle.hero(audio,"warrior","defense")
	check(audio.voices.filter(func(voice): return voice.playing and voice.get_meta("voice_group", "") == "warrior").size() == 1, "one simultaneous vocal performance per hero")
	check(audio.voices.size() == 12, "sound variety retains fixed voice pool")
	if DisplayServer.get_name() != "headless":
		for voice in audio.voices: voice.stop()
		audio.last_played.clear()
		var recorder = AudioEffectRecord.new()
		AudioServer.add_bus_effect(0, recorder)
		recorder.set_recording_active(true)
		for id in ["warrior", "guardian", "rogue", "mage"]:
			Battle.hero(audio,id,"attack")
			await create_timer(1.15).timeout
			Battle.hero(audio,id,"defense")
			await create_timer(1.15).timeout
		for id in ["rat", "skeleton", "forest_wolf", "fire_elemental", "forest_boss", "volcano_boss"]:
			Battle.enemy(audio,id)
			await create_timer(0.9).timeout
		for i in range(4):
			audio.play_sfx("shield_impact")
			await create_timer(0.65).timeout
		recorder.set_recording_active(false)
		var recording = recorder.get_recording()
		check(recording != null and recording.data.size() > 0, "native human, machine and metal mix recorded")
		recording.save_to_wav(preload("res://tests/artifacts.gd").path("battle_audio_2026_10_18/preview.wav"))
		AudioServer.remove_bus_effect(0, AudioServer.get_bus_effect_count(0)-1)
	audio.queue_free()
	await process_frame
	print("BATTLE AUDIO: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
