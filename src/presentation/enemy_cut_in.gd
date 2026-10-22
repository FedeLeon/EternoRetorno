extends "res://src/presentation/comic_cut_in.gd"
const ATTACK_DURATION = 0.92
const COLORS = {
	"crypt_bandit":Color("ad8cbb"),"beast_6":Color("81d5ef"),
	"flying_1":Color("be617e"),"flying_6":Color("858fc6"),
	"crypt_wolf":Color("e1a56a"),"bandit_7":Color("e38856"),
	"elemental_3": Color("8bbfea"), "elemental_4": Color("8fcc56"),
	"beast_3": Color("c68657"), "bandit_6": Color("8aa4bc"),
	"bandit_4": Color("ef9246"), "flying_5": Color("77c8d8"),
	"skeleton_4": Color("b566eb"), "elemental_0": Color("ff8533"),
	"crypt_beetle": Color("db9b51"), "bandit_2": Color("c99968"),
	"beast_4": Color("9ec64f"), "elemental_6": Color("88bf65"),
	"crypt_bat": Color("b272d7"), "crypt_lancer": Color("afc5d7"),
	"crypt_shaman": Color("f39149"), "crypt_slime": Color("94d23d"),
	"skeleton_6": Color("719ed9"), "crypt_automaton": Color("efa653"),
	"goblin_0": Color("acc252"), "goblin_2": Color("d5ad68"),
	"goblin_3": Color("9ce157"), "goblin_7": Color("ea7148"),
	"beast_0": Color("b1c4da"), "beast_1": Color("cba26a"), "beast_5": Color("e2a862"),
	"skeleton_0": Color("e9b375"), "skeleton_2": Color("9ccd88"),
	"skeleton_3": Color("82b9de"), "skeleton_5": Color("e68866"),
	"elemental_2": Color("b8bd82"), "elemental_7": Color("b880ef"),
	"goblin_1": Color("bd8155"), "goblin_4": Color("eaa352"), "goblin_5": Color("cbb06c"), "goblin_6": Color("b58868"), "beast_2": Color("b480cf"), "beast_7": Color("a79dbb")
}
var visual_id: String
var action: String = "attack"

static func artwork(visual: String, kind: String = "attack") -> String:
	if kind not in ["attack", "defense"]: return ""
	var visuals = preload("res://src/data/json_catalog.gd").dictionary("res://data/enemy_visuals.json")
	return visuals.get(visual, {}).get("foreground", {}).get(kind, "")

static func play(parent: Control, visual: String, kind: String = "attack") -> Control:
	if not preload("res://src/presentation/preferences.gd").cutins(): return null
	var path = artwork(visual, kind)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var effect = new()
	effect.visual_id = visual
	effect.action = kind
	if kind == "attack": effect.duration = ATTACK_DURATION
	effect.accent = COLORS.get(visual, Color("eca864"))
	effect.static_illustration = true
	effect.enhanced_lights = true
	effect.full_view_rays = true
	effect.defensive_effect = kind == "defense"
	effect.texture_path = path
	effect.from_right = true
	effect.align_right = true
	effect.name = "EnemyCutIn"
	parent.add_child(effect)
	return effect
