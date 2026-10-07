extends RefCounted
# End-of-run presentation only; settlement already committed by Game.
static func build(ui: Control) -> void:
	var won = ui.screen == "victory"
	ui.label_at("EL CICLO CONTINÚA" if won else "EL CICLO RECOMIENZA", 170, 99, 940, 50, 20, ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("El camino queda atrás" if won else "El mundo los recuerda", 100, 166, 1080, 100, 55).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var summary: Dictionary = ui.game.run.get("adventure_summary", {})
	ui.label_at("Piso %d · Retorno %d · %s" % [summary.get("floor",1), summary.get("difficulty",0), {"normal":"Sin condición", "tainted":"Profanada", "dangerous":"Expedición peligrosa"}.get(summary.get("variant","normal"),"Sin condición")], 180, 142, 920, 25, 16, ui.MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var stats: Dictionary = summary.get("statistics", {})
	var party_names: Array = ui.game.run.party.map(func(id): return ui.game.content.heroes[id].name)
	ui.label_at(" + ".join(party_names), 180, 250, 920, 35, 22, ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var victory_text = "Completaste los pisos de esta expedición.\nLa aventura está completa." if int(ui.game.run.get("floor_count", 1)) > 1 else "Completaste la cripta de los ecos."
	ui.label_at(victory_text if won else ("Decidiste volver al campamento.\nLos contratos se renuevan para el próximo intento." if summary.get("abandoned", false) else "Ambos compañeros han caído.\nOtra pareja. Otro mazo. Una nueva oportunidad."), 180, 282, 920, 105, 25, ui.MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("%d salas recorridas  ·  %d cartas al final" % [int(ui.game.run.get("rooms_completed", 0)) + ui.game.run.visited.size(), ui.game.run.summary_cards], 180, 390, 920, 35, 21, ui.TEXT).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("%d combates · %d élites · %d guardianes · %d almas · %d daño recibido" % [stats.get("battles",0),stats.get("elites",0),stats.get("bosses",0),stats.get("souls",0),stats.get("damage_taken",0)], 110, 428, 1060, 34, 20, ui.TEXT).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var relic_names: Array[String] = []
	for id in summary.get("relics", []):
		if ui.game.content.relics.has(id): relic_names.append(ui.game.content.relics[id].name)
	var relic_label = ui.label_at("Reliquias (%d): " % relic_names.size() + (", ".join(relic_names.slice(0,4)) + ("…" if relic_names.size() > 4 else "") if not relic_names.is_empty() else "ninguna"), 120, 465, 1040, 48, 17, ui.GOLD)
	relic_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	relic_label.mouse_filter = Control.MOUSE_FILTER_STOP
	relic_label.tooltip_text = "\n".join(relic_names)
	ui.label_at("Ecos desbloqueados: " + ", ".join(ui.game.run.new_unlocks) if not ui.game.run.new_unlocks.is_empty() else "Tus desbloqueos anteriores se conservan.", 170, 519, 940, 34, 18, ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.button("Volver al campamento", 322, 581, 310, 64, ui.open_base_camp)
	ui.button("Colección de ecos", 650, 581, 310, 64, ui.open_collection)
	var result: Dictionary = ui.game.run.get("contract_result", {})
	if not result.is_empty():
		ui.label_at(("%s · +%d almas" % [result.name, result.reward]) if result.complete else (result.name + " · no completado. Tres nuevas ofertas disponibles."), 120, 552, 1040, 26, 17, ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
