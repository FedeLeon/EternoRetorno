extends RefCounted
# Arena decoration and the action log. Status icons live with the intentions.
static func enemy(ui: Control, parent: Control, unit: Dictionary) -> void:
	if unit.hp > 0 and int(unit.get("root_hp", 0)) > 0:
		var roots = TextureRect.new()
		roots.texture = preload("res://assets/combat_depth/roots.png")
		roots.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		roots.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		roots.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(roots, 24, preload("res://src/ui/components/combat_layout.gd").ground_for(ui) - preload("res://src/ui/components/combat_layout.gd").TOP - 76, 168, 76, parent)

static func open_journal(ui: Control) -> void:
	if ui.combat_busy: return
	ui.close_modal()
	var entries: Array = ui.game.run.combat.get("journal", [])
	preload("res://src/ui/components/reading_dialog.gd").open(ui, "Registro del combate", "Todavía no hubo acciones." if entries.is_empty() else "\n".join(entries))
