extends RefCounted
# Moves the actor only. The attack receipt has already been resolved and saved.
static func applies(card: Dictionary, hero: String) -> bool:
	if int(card.get("damage",0)) <= 0: return false
	if card.has("attack_delivery"): return card.attack_delivery == "melee"
	return hero in ["warrior","guardian","rogue"] and card.get("id","") != "rogue_plague"

static func approach(layer: Control, actor: Control, target: Control) -> Dictionary:
	var state = {"parent":actor.get_parent(),"index":actor.get_index(),"position":actor.position,"scale":actor.scale,"pivot":actor.pivot_offset,"z":actor.z_index,"relative":actor.z_as_relative,"global_position":actor.global_position}
	var feet = actor.get_global_transform() * Vector2(actor.size.x/2,actor.size.y)
	var target_feet = target.get_global_transform() * Vector2(target.size.x/2,target.size.y)
	actor.reparent(layer,true)
	actor.z_as_relative = false
	actor.z_index = 60
	actor.set_meta("melee_active",true)
	var tween = actor.create_tween()
	# Keep the same ground baseline; only move horizontally towards the target.
	tween.tween_property(actor,"global_position",actor.global_position+Vector2(target_feet.x-100-feet.x,0),0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	return state

static func retreat(actor: Control, state: Dictionary) -> void:
	if not is_instance_valid(actor): return
	if actor.sprite.animation != "idle" and actor.sprite.is_playing(): await actor.sprite.animation_finished
	if not is_instance_valid(actor) or not is_instance_valid(state.parent): return
	var tween = actor.create_tween()
	tween.tween_property(actor,"global_position",state.global_position,0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	actor.reparent(state.parent,true)
	actor.get_parent().move_child(actor,mini(state.index,actor.get_parent().get_child_count()-1))
	actor.pivot_offset = state.pivot
	actor.scale = state.scale
	actor.position = state.position
	actor.z_index = state.z
	actor.z_as_relative = state.relative
	actor.set_meta("melee_active",false)
