extends RefCounted
# Gentle transient ducking leaves music audible and preserves the user's volume.
var music_level = 0.75
var duck_db = 0.0
var remaining = 0.0

func configure(settings: Dictionary) -> void:
	music_level = clampf(float(settings.get("music_volume",0.75)),0,1)
	apply()

func accent(event: String) -> void:
	if event in ["sword_heavy","shield_bash","flesh_impact","shield_impact","fire_spell","victory","death"]:
		duck_db = -3.0
		remaining = 0.12 if event != "victory" else 0.6
		apply()

func update(delta: float) -> void:
	if remaining > 0:
		remaining -= delta
	elif duck_db < 0:
		duck_db = minf(0,duck_db+delta*9)
		apply()

func apply() -> void:
	var bus = AudioServer.get_bus_index("Music")
	if bus >= 0: AudioServer.set_bus_volume_db(bus,linear_to_db(maxf(0.001,music_level))+duck_db)

static func install_limiter() -> void:
	for i in range(AudioServer.get_bus_effect_count(0)):
		if AudioServer.get_bus_effect(0,i).resource_name == "EternoRetornoLimiter": return
	var limiter = AudioEffectLimiter.new()
	limiter.resource_name = "EternoRetornoLimiter"
	limiter.ceiling_db = -1.0
	limiter.threshold_db = -2.0
	AudioServer.add_bus_effect(0,limiter)
