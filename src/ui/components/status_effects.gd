extends Control
const Indicator = preload("res://src/ui/components/block_indicator.gd")
const POISON_ICON = preload("res://assets/ui/poison.svg")

# Presentation snapshot. Absent or inactive effects occupy no space.
var unit: Dictionary = {}
# Relative to this control; supplied by the screen beside its health bar.
var block_position = Vector2.ZERO
var poison_position = Vector2(-1, -1)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if unit.get("hp", 0) <= 0:
		return
	var active: Array = []
	for effect in ["block", "poison"]:
		if int(unit.get(effect, 0)) > 0:
			active.append(effect)
	for i in range(active.size()):
		var effect = active[i]
		var indicator = Indicator.new()
		indicator.name = "Block" if effect == "block" else "Poison"
		indicator.amount = int(unit[effect])
		if effect == "poison":
			indicator.icon_texture = POISON_ICON
		indicator.position = poison_position if effect == "poison" and poison_position.x >= 0 else Vector2((size.x - 76) / 2, 0)
		if effect == "block":
			indicator.position = block_position
			indicator.number_height = 18
			indicator.explanation = "Bloqueo activo"
		indicator.size = Vector2(76, 28)
		add_child(indicator)
		if effect == "block": indicator.update_active_block(indicator.amount)
