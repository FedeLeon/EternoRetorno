extends "res://src/presentation/comic_cut_in.gd"
const COLORS = {
	"warrior": Color("ab47ed"), "guardian": Color("efc46e"),
	"rogue": Color("94d23d"), "mage": Color("688bff"),
	"cleric": Color("ffdb83"), "ranger": Color("64bdff")
}
static var last_variant: Dictionary = {}
var attack_variant = 0
var hero_id: String
var action = "attack"

static func play(parent: Control, hero: String, kind: String = "attack", variant: int = -1) -> Control:
	if not preload("res://src/presentation/preferences.gd").cutins(): return null
	if not COLORS.has(hero) or kind not in ["attack", "defense"]:
		return null
	var effect = new()
	effect.hero_id = hero
	effect.duration = 0.96 # +33% presentation time; gameplay and enemy cut-ins unchanged.
	effect.action = kind
	effect.accent = COLORS[hero]
	effect.framing_scale = 1.28
	effect.framing_offset = Vector2(-0.10, 0.12)
	effect.frame_grid = Vector2i(4, 4)
	effect.enhanced_lights = true
	effect.defensive_effect = kind == "defense"
	if kind == "defense":
		effect.texture_path = "res://assets/comic/motion/%s_defense.png" % hero
	else:
		# Visual rotation only: never consumes the adventure RNG or repeats adjacent hits.
		effect.attack_variant = (int(last_variant.get(hero, 0)) + 1) % 4 if variant < 0 else clampi(variant, 0, 3)
		last_variant[hero] = effect.attack_variant
		effect.texture_path = "res://assets/comic/motion/%s_%d.png" % [hero, effect.attack_variant]
	effect.name = "HeroCutIn"
	parent.add_child(effect)
	return effect
