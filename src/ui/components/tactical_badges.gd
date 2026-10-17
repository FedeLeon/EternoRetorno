extends RefCounted
# Arena decoration and the action log. Status icons live with the intentions.
static func enemy(ui: Control, parent: Control, unit: Dictionary) -> Control:
	if unit.hp > 0 and int(unit.get("root_hp", 0)) > 0:
		var cables = preload("res://src/presentation/ground_cables.gd").new()
		cables.name = "GroundCables"
		var layout = preload("res://src/ui/components/combat_layout.gd")
		ui.rect(cables, 7, layout.ground_for(ui) - layout.TOP - 1, 200, 8, parent)
		parent.move_child(cables, 0) # Draw underneath the machine, not across its legs.
		return cables
	return null

static func open_journal(ui: Control) -> void:
	if ui.combat_busy: return
	ui.close_modal()
	var entries: Array = ui.game.run.combat.get("journal", [])
	preload("res://src/ui/components/reading_dialog.gd").open(ui, "Registro del combate", "Todavía no hubo acciones." if entries.is_empty() else "\n".join(entries))
