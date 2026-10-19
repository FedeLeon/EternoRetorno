extends "res://src/presentation/comic_cut_in.gd"
const COLORS = {
	"warrior": Color("bb62f0"), "guardian": Color("ffb34f"),
	"rogue": Color("78ef8d"), "mage": Color("5de5ed")
}
static var attack_cycles: Dictionary = {}
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
	effect.static_illustration = true
	effect.enhanced_lights = true
	effect.full_view_rays = true
	effect.sketch_style = false
	effect.defensive_effect = kind == "defense"
	var variant = int(attack_cycles.get(hero, 0)) if kind == "attack" else 0
	if kind == "attack": attack_cycles[hero] = (variant + 1) % 3
	effect.texture_path = "res://assets/comic/static/variants/%s_attack_%d.png" % [hero, variant] if variant > 0 else "res://assets/comic/static/%s_%s.png" % [hero, kind]
	effect.name = "HeroCutIn"
	parent.add_child(effect)
	return effect
