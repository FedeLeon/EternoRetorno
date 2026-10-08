extends Control
const Indicator = preload("res://src/ui/components/block_indicator.gd")
# Active shield remains beside life. Other effects live in BattleEffectStrip.
var unit: Dictionary = {}
var block_position = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if unit.get("hp", 0) <= 0: return
	# Retain the hidden zero-block indicator for committed action playback.
	var indicator = Indicator.new()
	indicator.name = "Block"
	indicator.amount = int(unit.get("block", 0))
	indicator.overlay_number = true
	indicator.position = block_position
	indicator.number_height = 18
	indicator.explanation = "Bloqueo activo"
	add_child(indicator)
	indicator.update_active_block(indicator.amount)
