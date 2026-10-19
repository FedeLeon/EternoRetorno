extends RefCounted
## Shared battlefield geometry. Reserve a floor band above the raised hand.
const TOP = 78.0
const INFO_BOTTOM = 410.0
const GROUND = 347.0
const INTENT_ROW_HEIGHT = 44.0
const HAND_TOP = 414.0
const SELECTED_SIZE = Vector2(202, 302)

const LIFE_GAP = 8.0
const LIFE_HEIGHT = 18.0
const EFFECT_GAP = 8.0
const INTENT_TOP = 76.0

static func ground_for(ui: Control) -> float:
	var rows = 0
	for i in range(ui.game.run.combat.enemies.size()):
		var entries = preload("res://src/ui/components/battle_effect_snapshot.gd").enemy(ui.game, i)
		rows = maxi(rows, ceili(entries.size() / 6.0))
	for i in range(ui.game.run.heroes.size()):
		var entries = preload("res://src/ui/components/battle_effect_snapshot.gd").hero(ui.game, i)
		rows = maxi(rows, ceili(entries.size() / 6.0))
	return minf(GROUND, INFO_BOTTOM - LIFE_GAP - LIFE_HEIGHT - EFFECT_GAP - rows * 33)

static func hero_ground_for(_ui: Control, ground: float) -> float:
	# Life and statuses now occupy the same floor band on both sides.
	return ground

static func place_hero(actor: Control, ground: float) -> void:
	actor.position.y += ground - (actor.get_global_transform() * Vector2(0, actor.size.y)).y

