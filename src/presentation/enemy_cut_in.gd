extends "res://src/presentation/comic_cut_in.gd"
const COLORS = {
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

static func play(parent: Control, visual: String) -> Control:
	if not COLORS.has(visual):
		return null
	var effect = new()
	effect.visual_id = visual
	effect.accent = COLORS[visual]
	effect.texture_path = "res://assets/comic/enemies/%s.png" % visual
	effect.from_right = true
	effect.name = "EnemyCutIn"
	parent.add_child(effect)
	return effect
