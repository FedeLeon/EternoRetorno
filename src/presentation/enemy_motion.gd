extends RefCounted
## Visual timing profiles; damage and targets have already been committed.
static func style(visual: String, definition: Dictionary) -> String:
	if definition.has("attack_style"): return definition.attack_style
	if visual.begins_with("elemental") or visual in ["crypt_shaman", "skeleton_4", "goblin_3"]: return "magic"
	if visual in ["bandit_2", "bandit_6", "skeleton_2", "goblin_2"]: return "ranged"
	if definition.motion == "fly": return "flight"
	if visual.begins_with("beast") or visual in ["crypt_wolf", "crypt_slime"]: return "beast"
	return "heavy" if visual in ["crypt_automaton", "skeleton_6", "bandit_5", "bandit_7"] else "blade"

static func play(actor: Control) -> void:
	var sprite: Sprite2D = actor.sprite
	var definition: Dictionary = actor.entries()[actor.visual_id]
	var kind = style(actor.visual_id, definition)
	var origin = sprite.position
	var drawn = actor.has_motion_frames and int(definition.get("attack_frames", 0)) == 4
	var timings = tempo(kind, actor.visual_id)
	var windup: float = timings[0]
	var strike: float = timings[1]
	var hold: float = timings[2]
	var recover: float = timings[3]
	var reach = {"magic":5.0,"ranged":7.0,"flight":22.0,"beast":26.0,"heavy":19.0}.get(kind,16.0)
	if actor.visual_id == "crypt_lancer": reach = 24.0
	if drawn: sprite.frame = 4
	var tween: Tween = actor.tween
	tween.tween_property(sprite,"position:x",origin.x+6,windup*0.75).set_trans(Tween.TRANS_SINE)

	if kind in ["flight","beast"]: tween.parallel().tween_property(sprite,"position:y",origin.y-6,windup*0.75)
	if kind == "magic": tween.parallel().tween_property(sprite,"modulate",Color(1.15,1.1,1.3),windup*0.75)
	if kind == "heavy": tween.parallel().tween_property(sprite,"rotation",0.025,windup*0.75)
	if drawn: tween.tween_callback(func(): sprite.frame = 5)
	tween.tween_interval(windup * 0.25)
	if drawn: tween.tween_callback(func(): sprite.frame = 6)
	tween.tween_property(sprite,"position:x",origin.x-reach,strike).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if kind in ["flight","beast"]: tween.parallel().tween_property(sprite,"position:y",origin.y-3,strike)
	if kind == "heavy": tween.parallel().tween_property(sprite,"rotation",-0.025,strike)
	tween.tween_callback(func():preload("res://src/presentation/actor_attack_trail.gd").echo(sprite))
	tween.tween_interval(hold)
	if drawn: tween.tween_callback(func(): sprite.frame = 7)
	tween.tween_property(sprite,"position",origin,recover).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite,"rotation",0.0,recover)
	tween.parallel().tween_property(sprite,"modulate",Color.WHITE,recover)

# Heavy machines telegraph their mass; fast units coil and spring. No scaling.
static func tempo(kind: String, visual: String) -> Array:
	if visual in ["crypt_automaton", "goblin_7", "flying_3"]: return [0.24, 0.14, 0.10, 0.23]
	match kind:
		"heavy": return [0.18, 0.12, 0.08, 0.16]
		"magic": return [0.20, 0.10, 0.08, 0.16]
		"ranged": return [0.18, 0.08, 0.06, 0.20]
		"flight", "beast": return [0.16, 0.10, 0.06, 0.19]
	return [0.16, 0.11, 0.08, 0.18]
