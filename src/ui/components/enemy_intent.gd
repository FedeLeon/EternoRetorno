extends Control
const BlockIndicator = preload("res://src/ui/components/block_indicator.gd")
const HEROES = ["warrior", "guardian", "rogue", "mage", "cleric", "ranger"]
var intent: Dictionary = {}
var heroes: Array = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var damage = int(intent.get("damage", 0))
	var block = int(intent.get("block", 0))
	var targets: Array = []
	if damage > 0:
		for i in range(heroes.size()):
			if heroes[i].hp > 0 and (intent.get("all", false) or i == int(intent.get("target", -1))):
				targets.append(heroes[i].id)
	var width = (68 + targets.size() * 39 if damage > 0 else 0) + (72 if block > 0 else 0)
	var x = (size.x - width) / 2.0
	if damage > 0:
		var attack = BlockIndicator.new()
		attack.name = "Attack"
		attack.amount = damage
		attack.icon_texture = preload("res://assets/ui/sword.svg")
		attack.position = Vector2(x, 5)
		add_child(attack)
		x += 68
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
	if block > 0:
		var shield = BlockIndicator.new()
		shield.name = "Block"
		shield.amount = block
		shield.position = Vector2(x, 5)
		add_child(shield)
