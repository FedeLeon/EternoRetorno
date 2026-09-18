extends Control
const BlockIndicator = preload("res://src/ui/components/block_indicator.gd")
const HEROES = ["warrior", "guardian", "rogue", "mage", "cleric", "ranger"]
var intent: Dictionary = {}
var heroes: Array = []

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
	var width = (68 + targets.size() * 39 if damage > 0 else 0) + (72 if block > 0 else 0) + (68 if counter > 0 else 0)
	var x = (size.x - width) / 2.0
	if width > 0:
		preload("res://src/ui/components/combat_backplate.gd").attach(self, Rect2(x - 6, -1, width + 12, 43))
	if damage > 0:
		var attack = BlockIndicator.new()
		attack.name = "Attack"
		attack.amount = damage
		attack.explanation = "El enemigo planea atacar por %d de daño%s." % [damage, " a ambos héroes" if intent.get("all", false) else " al héroe indicado"]
		attack.icon_texture = preload("res://assets/ui/sword.svg")
		attack.position = Vector2(x, 5)
		add_child(attack)
		x += 68
	if block > 0:
		var shield = BlockIndicator.new()
		shield.name = "Block"
		shield.amount = block
		shield.explanation = "El enemigo planea obtener %d de bloqueo al actuar. Todavía no es bloqueo activo." % block
		shield.number_height = 18
		shield.gaining_block = true
		shield.position = Vector2(x, 5)
		add_child(shield)

		x += 72
	if counter > 0:
		var counter_icon = BlockIndicator.new()
		counter_icon.name = "Counter"
		counter_icon.amount = 4
		counter_icon.number_height = 18
		counter_icon.icon_texture = preload("res://assets/ui/counter.svg")
		counter_icon.explanation = "Contraataque activo durante este turno: devuelve 4 de daño al atacante por cada golpe recibido, si sobrevive. Tu bloqueo puede absorberlo."
		counter_icon.position = Vector2(x, 5)
		add_child(counter_icon)
		x += 68
	if damage > 0:
		for id in targets:
			var frame = Panel.new()
			frame.name = "Target_" + id
			frame.position = Vector2(x, 0)
			frame.size = Vector2(34, 38)
			var style = StyleBoxFlat.new()
			style.bg_color = Color("171b28")
			style.border_color = Color("bc9b66")
			style.set_border_width_all(1)
			frame.add_theme_stylebox_override("panel", style)
			frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(frame)
			var face = TextureRect.new()
			var crop = AtlasTexture.new()
			crop.atlas = preload("res://assets/camp/front-128.png")
			crop.region = Rect2(HEROES.find(id) * 128 + 48, 27, 32, 36)
			face.texture = crop
			face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			face.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			face.position = Vector2.ONE
			face.size = Vector2(32, 36)
			face.mouse_filter = Control.MOUSE_FILTER_IGNORE
			frame.add_child(face)
			x += 39
