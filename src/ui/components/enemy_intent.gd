extends Control
const BlockIndicator = preload("res://src/ui/components/block_indicator.gd")
const Portrait = preload("res://src/ui/components/refuge_portrait.gd")
var intent: Dictionary = {}
var heroes: Array = []
var effects: Array = []
var ui: Control
var compact_effects = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var damage = int(intent.get("damage", 0))
	var block = int(intent.get("block", 0))
	var counter = int(intent.get("counter", 0))
	var targets: Array = []
	if damage > 0:
		for i in range(heroes.size()):
			if heroes[i].hp > 0 and (intent.get("all", false) or i == int(intent.get("target", -1))):
				targets.append(heroes[i].id)
	var indicator_width = (52 if damage > 0 else 0) + (52 if block > 0 else 0) + (52 if counter > 0 else 0)
	# Two portraits plus attack/guard/counter must still fit the actor column.
	var target_step = minf(30.0, (size.x - indicator_width) / maxi(1, targets.size()))
	var width = indicator_width + targets.size() * target_step
	var x = (size.x - width) / 2.0
	if width > 0:
		preload("res://src/ui/components/combat_backplate.gd").attach(self, Rect2(x - 4, 0, width + 8, 34 if compact_effects else 38))
	if damage > 0:
		var attack = BlockIndicator.new()
		attack.name = "Attack"
		attack.amount = damage
		attack.explanation = "El enemigo planea atacar por %d de daño%s." % [damage, " a ambos héroes" if intent.get("all", false) else " al héroe indicado"]
		attack.icon_texture = load("res://assets/battle_effects/attack.png")
		attack.compact = true
		attack.number_height = 18
		attack.position = Vector2(x, 2)
		add_child(attack)
		x += 52
	if damage > 0:
		for id in targets:
			var portrait: Texture2D = Portrait.face_texture(id)
			var face_width = target_step - 6
			var face_size = Vector2(face_width, face_width * portrait.get_height() / float(portrait.get_width()))
			var frame = Panel.new()
			frame.name = "Target_" + id
			frame.position = Vector2(x, 2)
			frame.size = face_size + Vector2(4, 4)
			var style = StyleBoxFlat.new()
			style.bg_color = Color("171b28")
			style.border_color = Color(Portrait.COLORS[id])
			style.set_border_width_all(2)
			frame.add_theme_stylebox_override("panel", style)
			frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(frame)
			var face = TextureRect.new()
			face.name = "Face"
			face.texture = portrait
			face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			face.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			face.position = Vector2(2, 2)
			face.size = face_size
			face.mouse_filter = Control.MOUSE_FILTER_IGNORE
			frame.add_child(face)
			x += target_step
	if block > 0:
		var shield = BlockIndicator.new()
		shield.name = "Block"
		shield.amount = block
		shield.explanation = "El enemigo planea obtener %d de bloqueo al actuar. Todavía no es bloqueo activo." % block
		shield.number_height = 18
		shield.gaining_block = true
		shield.compact = true
		shield.icon_texture = load("res://assets/battle_effects/guard.png")
		shield.position = Vector2(x, 2)
		add_child(shield)

		x += 52
	if counter > 0:
		var counter_icon = BlockIndicator.new()
		counter_icon.name = "Counter"
		counter_icon.amount = 4
		counter_icon.number_height = 18
		counter_icon.icon_texture = load("res://assets/battle_effects/counter.png")
		counter_icon.compact = true
		counter_icon.explanation = "Contraataque activo durante este turno: devuelve 4 de daño al atacante por cada golpe recibido, si sobrevive. Tu bloqueo puede absorberlo."
		counter_icon.position = Vector2(x, 2)
		add_child(counter_icon)
		x += 52
	if not effects.is_empty():
		var strip = preload("res://src/ui/components/battle_effect_strip.gd").new()
		strip.name = "EnemyEffects"
		strip.ui = ui
		strip.entries = effects
		strip.compact = compact_effects
		strip.position = Vector2(0, preload("res://src/ui/components/combat_layout.gd").INTENT_ROW_HEIGHT if compact_effects else 40)
		strip.size = Vector2(size.x, strip.height_for(effects.size(), compact_effects))
		add_child(strip)
