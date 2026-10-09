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
	var reach = {"magic":5.0,"ranged":7.0,"flight":22.0,"beast":26.0,"heavy":19.0}.get(kind,16.0)
	if actor.visual_id == "crypt_lancer": reach = 24.0
	if drawn: sprite.frame = 4
	var tween: Tween = actor.tween
	tween.tween_property(sprite,"position:x",origin.x+6,0.12).set_trans(Tween.TRANS_SINE)
	if drawn: tween.parallel().tween_property(sprite,"frame",5,0.12)
	if kind in ["flight","beast"]: tween.parallel().tween_property(sprite,"position:y",origin.y-6,0.12)
	if kind == "magic": tween.parallel().tween_property(sprite,"modulate",Color(1.15,1.1,1.3),0.12)
	if kind == "heavy": tween.parallel().tween_property(sprite,"rotation",0.055,0.12)
	tween.tween_property(sprite,"position:x",origin.x-reach,0.11).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if drawn: tween.parallel().tween_property(sprite,"frame",6,0.11)
	if kind in ["flight","beast"]: tween.parallel().tween_property(sprite,"position:y",origin.y-3,0.11)
	if kind == "heavy": tween.parallel().tween_property(sprite,"rotation",-0.055,0.11)
	tween.tween_callback(func():preload("res://src/presentation/actor_attack_trail.gd").echo(sprite))
	tween.tween_interval(0.07)
	tween.tween_property(sprite,"position",origin,0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if drawn: tween.parallel().tween_property(sprite,"frame",7,0.16)
	tween.parallel().tween_property(sprite,"rotation",0.0,0.16)
	tween.parallel().tween_property(sprite,"modulate",Color.WHITE,0.16)
