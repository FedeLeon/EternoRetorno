extends Control
const Indicator = preload("res://src/ui/components/block_indicator.gd")
const POISON_ICON = preload("res://assets/ui/poison.svg")

# Presentation snapshot. Absent or inactive effects occupy no space.
var unit: Dictionary = {}

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
		indicator.position = Vector2((size.x - active.size() * 80) / 2 + i * 80, 0)
		indicator.size = Vector2(76, 28)
		add_child(indicator)
