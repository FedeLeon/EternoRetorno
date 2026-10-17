extends RefCounted
## Shared battlefield geometry. Reserve a floor band above the raised hand.
const TOP = 78.0
const INFO_BOTTOM = 410.0
const GROUND = 347.0
const INTENT_ROW_HEIGHT = 34.0
const HAND_TOP = 414.0
const SELECTED_SIZE = Vector2(202, 302)
const HERO_LOWERING = 16.0

static func ground_for(ui: Control) -> float:
	var rows = 0
	for i in range(ui.game.run.combat.enemies.size()):
		var entries = preload("res://src/ui/components/battle_effect_snapshot.gd").enemy(ui.game, i)
		rows = maxi(rows, ceili(entries.size() / 6.0))
	for i in range(ui.game.run.heroes.size()):
		var entries = preload("res://src/ui/components/battle_effect_snapshot.gd").hero(ui.game, i)
		rows = maxi(rows, maxi(0, ceili(entries.size() / 6.0) - 1))
	return minf(GROUND, INFO_BOTTOM - 8 - INTENT_ROW_HEIGHT - rows * 33)

static func hero_ground_for(ui: Control, ground: float) -> float:
	var offset = HERO_LOWERING
	for i in range(ui.game.run.heroes.size()):
		var count = preload("res://src/ui/components/battle_effect_snapshot.gd").hero(ui.game, i).size()
		var height = preload("res://src/ui/components/battle_effect_strip.gd").height_for(count, true)
		offset = minf(offset, maxf(0, INFO_BOTTOM - ground - 8 - height))
	return ground + offset

static func place_hero(actor: Control, ground: float) -> void:
	var bottom = preload("res://src/presentation/hero_grounding.gd").bottom(actor.sprite.sprite_frames.get_frame_texture("idle", 0))
	var foot = actor.sprite.position.y + bottom * actor.sprite.scale.y
	actor.position.y += ground - (actor.get_global_transform() * Vector2(0, foot)).y

