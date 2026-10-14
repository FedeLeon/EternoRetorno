extends "res://src/presentation/comic_cut_in.gd"
const COLORS = {
	"warrior": Color("9c78ba"), "guardian": Color("b69bbf"),
	"rogue": Color("8973a3"), "mage": Color("b68ed7")
}
var hero_id: String
var action = "attack"

static func play(parent: Control, hero: String, kind: String = "attack") -> Control:
	if not preload("res://src/presentation/preferences.gd").cutins(): return null
	if not COLORS.has(hero) or kind not in ["attack", "defense"]:
		return null
	var effect = new()
	effect.hero_id = hero
	effect.duration = 0.96
	effect.action = kind
	effect.accent = COLORS[hero]
	effect.framing_scale = 1.28
	effect.framing_offset = Vector2(-0.10, 0.12)
	effect.static_illustration = true
	effect.enhanced_lights = true
	effect.sketch_style = true
	effect.defensive_effect = kind == "defense"
	effect.texture_path = "res://assets/comic/static/%s_%s.png" % [hero, kind]
	effect.name = "HeroCutIn"
	parent.add_child(effect)
	return effect
