extends RefCounted
# End-of-run presentation only; settlement already committed by Game.
static func build(ui: Control) -> void:
	var won = ui.screen == "victory"
	ui.label_at("EL CICLO CONTINÚA" if won else "EL CICLO RECOMIENZA", 170, 99, 940, 50, 20, ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("El camino queda atrás" if won else "El mundo los recuerda", 100, 166, 1080, 100, 55).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var victory_text = "Atravesaste la cripta y el Bosque de las Raíces.\nLa aventura está completa." if int(ui.game.run.get("floor_count", 1)) > 1 else "Completaste la cripta de los ecos."
	ui.label_at(victory_text if won else "Ambos compañeros han caído.\nOtra pareja. Otro mazo. Una nueva oportunidad.", 180, 282, 920, 105, 25, ui.MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("%d salas recorridas  ·  %d cartas al final" % [int(ui.game.run.get("rooms_completed", 0)) + ui.game.run.visited.size(), ui.game.run.summary_cards], 180, 408, 920, 40, 21, ui.TEXT).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("Ecos desbloqueados: " + ", ".join(ui.game.run.new_unlocks) if not ui.game.run.new_unlocks.is_empty() else "Tus desbloqueos anteriores se conservan.", 170, 470, 940, 65, 22, ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.button("Volver al campamento", 322, 581, 310, 64, ui.open_base_camp)
	ui.button("Colección de ecos", 650, 581, 310, 64, ui.open_collection)
	var result: Dictionary = ui.game.run.get("contract_result", {})
	if not result.is_empty():
		ui.label_at("Contrato completado. Recompensa entregada en el campamento." if result.complete else "Contrato no completado. Hay tres nuevas ofertas en el puesto.", 120, 540, 1040, 32, 19, ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
