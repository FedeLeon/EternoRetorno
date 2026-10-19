extends Node
# Persistent presentation audio: independent of screen rebuilds and game RNG.
signal sound_played(event: String)
signal context_changed(context: String)
const Routing = preload("res://src/audio/screen_audio.gd")
const BUSES = ["Music", "Ambience", "SFX"]
var catalog: Dictionary
var current_context = ""
var music_id = ""
var music: AudioStreamPlayer
var fading_music: AudioStreamPlayer
var music_tween: Tween
var ambience: Array[AudioStreamPlayer] = []
var voices: Array[AudioStreamPlayer] = []
var streams: Dictionary = {}
var last_variant: Dictionary = {}
var last_played: Dictionary = {}
var rng = RandomNumberGenerator.new()
var idle_seconds = 4.0
var played_count = 0
var mix = preload("res://src/audio/audio_mix.gd").new()

func _ready() -> void:
	name = "GameAudio"
	catalog = preload("res://src/data/json_catalog.gd").dictionary("res://data/audio.json")
	rng.randomize()
	for bus in BUSES:
		if AudioServer.get_bus_index(bus) < 0:
			# Godot 4.7.2 Web Sample mishandles add_bus(-1), shifting Master.
			# Growing the layout appends without reordering the browser graph.
			AudioServer.set_bus_count(AudioServer.bus_count + 1)
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
			AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
	for i in range(12): voices.append(player("SFX"))
	get_tree().node_added.connect(node_added)
	preload("res://src/audio/audio_mix.gd").install_limiter()

func _exit_tree() -> void:
	if music_tween != null and music_tween.is_valid(): music_tween.kill()
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
	streams.clear()

func player(bus: String) -> AudioStreamPlayer:
	var result = AudioStreamPlayer.new()
	result.bus = bus
	add_child(result)
	return result

func stream(id: String, loop: bool = false) -> AudioStream:
	var key = id + ("_loop" if loop else "")
	if not streams.has(key):
		var path: String = catalog.files.get(id, "")
		if path.is_empty(): return null
		var resource = load(path)
		if resource == null: return null
		resource = resource.duplicate()
		resource.loop = loop
		streams[key] = resource
	return streams[key]

func apply_settings(settings: Dictionary) -> void:
	mix.configure(settings)
	set_volume("Master", float(settings.get("volume", 1.0)))
	set_volume("Music", float(settings.get("music_volume", 0.75)))
	set_volume("SFX", float(settings.get("sfx_volume", 0.85)))
	set_volume("Ambience", float(settings.get("sfx_volume", 0.85)) * float(settings.get("ambience_volume", 1.0)))

func set_volume(bus: String, value: float) -> void:
	var index = AudioServer.get_bus_index(bus)
	value = clampf(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.0001)))
	AudioServer.set_bus_mute(index, value <= 0)

func select_screen(screen: String, run: Dictionary, return_screen: String = "") -> void:
	set_context(Routing.context(screen, run, return_screen))

func set_context(id: String) -> void:
	if id == "" or id == current_context: return
	var definition: Dictionary = catalog.contexts[id]
	var previous = current_context
	current_context = id
	change_music(definition.get("music", ""), float(definition.get("music_db", -1)))
	for channel in ambience:
		var fade = create_tween()
		fade.tween_property(channel,"volume_db",-60.0,0.4)
		fade.tween_callback(retire.bind(channel))
	ambience.clear()
	for entry in definition.get("ambience", []):
		var channel = player("Ambience")
		channel.stream = stream(entry.id, true)
		channel.volume_db = -60
		channel.play()
		create_tween().tween_property(channel,"volume_db",float(entry.get("db",-6)),0.4)
		ambience.append(channel)
	idle_seconds = rng.randf_range(4.0, 7.0)
	if (id.begins_with("reward") or id == "victory") and not previous.begins_with("reward"): play_sfx("victory")
	if id == "defeat": play_sfx("defeat")
	if id in ["market", "forge", "church", "refuge", "expeditions"] and previous != id: play_sfx("door", -5)
	context_changed.emit(id)

func change_music(id: String, gain: float) -> void:
	if id == music_id:
		if music_tween != null and music_tween.is_valid(): music_tween.kill()
		if is_instance_valid(fading_music):
			retire(fading_music)
			fading_music = null
		if music != null:
			music_tween = create_tween()
			music_tween.tween_property(music,"volume_db",gain,0.4)
		return # Buying, hovering or rebuilding a screen never restarts its theme.
	if music_tween != null and music_tween.is_valid(): music_tween.kill()
	if is_instance_valid(fading_music):
		retire(fading_music)
		fading_music = null
	fading_music = music
	music = null
	music_id = id
	music_tween = create_tween().set_parallel(true)
	if is_instance_valid(fading_music):
		var outgoing = fading_music
		music_tween.tween_property(outgoing, "volume_db", -60.0, 0.7)
	if not id.is_empty():
		music = player("Music")
		music.stream = stream(id, true)
		music.volume_db = -60
		music.play()
		music_tween.parallel().tween_property(music, "volume_db", gain, 0.7)
	if is_instance_valid(fading_music):
		var outgoing = fading_music
		music_tween.chain().tween_callback(func():
			if is_instance_valid(outgoing): retire(outgoing))

func retire(channel: AudioStreamPlayer) -> void:
	channel.stop()
	channel.stream = null
	channel.queue_free()

func play_sfx(event: String, gain: float = 0.0, bus: String = "SFX") -> void:
	var definition: Dictionary = catalog.events.get(event, {})
	if definition.is_empty(): return
	var now = Time.get_ticks_msec()
	if last_played.has(event) and now - int(last_played[event]) < int(definition.get("cooldown_ms", 0)):
		return
	last_played[event] = now
	var variants: Array = definition.files
	var choices = variants.filter(func(id): return id != last_variant.get(event,"")) if variants.size() > 1 else variants
	var id: String = choices[rng.randi_range(0, choices.size() - 1)]
	last_variant[event] = id
	var group: String = definition.get("voice_group", "")
	if group != "":
		for previous in voices:
			if previous.get_meta("voice_group", "") == group: previous.stop()
	var voice: AudioStreamPlayer = voices[0]
	for available in voices:
		if not available.playing:
			voice = available
			break
		if int(available.get_meta("started",0)) < int(voice.get_meta("started",0)): voice = available
	voice.stop()
	voice.bus = bus
	voice.stream = stream(id)
	voice.volume_db = float(definition.get("db", 0.0)) + gain
	voice.pitch_scale = rng.randf_range(0.96, 1.04) if definition.get("vary_pitch", true) else 1.0
	voice.play()
	voice.set_meta("voice_group", group)
	voice.set_meta("started",Time.get_ticks_msec())
	mix.accent(event)
	played_count += 1
	sound_played.emit(event)

func _process(delta: float) -> void:
	mix.update(delta/maxf(0.01,Engine.time_scale))
	if current_context.is_empty(): return
	idle_seconds -= delta
	if idle_seconds > 0: return
	var events: Array = catalog.contexts[current_context].get("idle", [])
	if not events.is_empty(): play_sfx(events[rng.randi_range(0, events.size() - 1)], -10, "Ambience")
	idle_seconds = rng.randf_range(5.0, 11.0)

func node_added(node: Node) -> void:
	if node is BaseButton: bind_button.call_deferred(node.get_instance_id())

func bind_button(instance_id: int) -> void:
	var button = instance_from_id(instance_id) as BaseButton
	if not is_instance_valid(button) or button.has_meta("audio_bound"): return
	button.set_meta("audio_bound", true)
	button.pressed.connect(func():
		var caption = button.text if button is Button else ""
		play_sfx("back" if caption in ["Volver", "Inicio", "Campamento", "Volver a héroes"] else "click"))
