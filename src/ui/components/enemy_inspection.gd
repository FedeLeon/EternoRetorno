extends RefCounted
## Read-only enemy information. A selected card keeps its normal target action.
static func open(ui: Control, index: int) -> void:
	if ui.combat_busy or ui.selected_card >= 0 or ui.selected_synergy != "": return
	var enemy: Dictionary = ui.game.run.combat.enemies[index]
	if enemy.hp <= 0: return
	var definition: Dictionary = ui.game.content.enemies[enemy.id]
	var role = {"protector":"Protector: al actuar da 3 de bloqueo a sus aliados.", "support":"Apoyo: al actuar cura 3 PV a sus aliados vivos.", "attacker":"Atacante"}.get(definition.get("role", "attacker"), "Atacante")
	var role_id = definition.get("role", "attacker")
	var role_icon = {"protector":"protector", "support":"healer"}.get(role_id, "attack")
	var rows: Array[Dictionary] = [
		{"id":"Health", "icon":"res://assets/battle_effects/vampiric.png", "text":"Vida: %d / %d PV" % [enemy.hp,enemy.max_hp]},
		{"id":"ActiveBlock", "icon":"res://assets/ui/block_active.svg", "text":"Bloqueo activo: %d" % enemy.block},
		{"id":"Role", "icon":"res://assets/battle_effects/%s.png" % role_icon, "text":role}
	]
	var intent: Dictionary = preload("res://src/rules/enemy_coordination.gd").intent(ui.game, enemy)
	if int(intent.get("damage", 0)) > 0:
		var target = "ambos héroes" if intent.get("all", false) else ui.game.content.heroes[ui.game.run.heroes[int(intent.get("target", 0))].id].name
		rows.append({"id":"Attack", "icon":"res://assets/battle_effects/attack.png", "text":"Atacará a %s por %d de daño." % [target, intent.damage]})
	if int(intent.get("block", 0)) > 0: rows.append({"id":"Guard", "icon":"res://assets/battle_effects/guard.png", "text":"Planea obtener %d de bloqueo." % intent.block})
	if int(intent.get("counter", 0)) > 0: rows.append({"id":"Counter", "icon":"res://assets/battle_effects/counter.png", "text":"Contraataque: devuelve 4 de daño por golpe recibido si sobrevive."})
	for effect in preload("res://src/ui/components/battle_effect_snapshot.gd").enemy(ui.game, index):
		if effect.id == role_icon: continue # Role description already covers this effect.
		rows.append({"id":"Effect_" + effect.id, "icon":effect.asset, "text":effect.title + ": " + effect.description})
	preload("res://src/ui/components/enemy_inspection_dialog.gd").open(ui, definition.name, rows)
