extends RefCounted
## Presentation only: the playback coordinator owns HP/block updates.
const Layout = preload("res://src/ui/components/combat_layout.gd")
const Strip = preload("res://src/ui/components/battle_effect_strip.gd")

static func build(ui: Control, target: Control, unit: Dictionary, entries: Array, ground: float, enemy: bool = false) -> Control:
	var y = ground - Layout.TOP + Layout.LIFE_GAP
	var health = ui.health_bar(unit, 22, y, target.size.x - 34, target)
	health.size.y = Layout.LIFE_HEIGHT
	health.combat_style = true
	health.refresh()
	health.z_as_relative = false
	health.z_index = 30
	var strip = Strip.new()
	strip.name = "EnemyEffects" if enemy else "HeroEffects"
	strip.ui = ui
	strip.entries = entries
	strip.compact = true
	ui.rect(strip, 0, y + Layout.LIFE_HEIGHT + Layout.EFFECT_GAP, target.size.x, Strip.height_for(entries.size(), true), target)
	var block = ui.StatusEffects.new()
	block.unit = unit
	block.z_as_relative = false
	block.z_index = 31
	# Larger backing for multi-digit block; raised tip stays above the status row.
	block.scale = Vector2.ONE * (32.0 / 42.0)
	ui.rect(block, 6, y + Layout.LIFE_HEIGHT / 2 - 16, target.size.x, 32, target)
	var update_visibility = func(hp: int):
		strip.visible = hp > 0
		block.visible = hp > 0
		if enemy: health.visible = hp > 0
	health.value_changed.connect(update_visibility)
	update_visibility.call(int(unit.hp))
	return health
