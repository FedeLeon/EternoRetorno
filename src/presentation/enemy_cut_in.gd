extends "res://src/presentation/comic_cut_in.gd"
const COLORS = {
	"crypt_bat": Color("b272d7"), "crypt_lancer": Color("afc5d7"),
	"crypt_shaman": Color("f39149"), "crypt_slime": Color("94d23d"),
	"skeleton_6": Color("719ed9"), "crypt_automaton": Color("efa653")
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
