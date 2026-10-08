extends RefCounted
# Presentation of the already committed result; no rewards or save mutations.
static func build(ui: Control) -> void:
	var won = ui.screen == "victory"
	var summary: Dictionary = ui.game.run.get("adventure_summary", {})
	var floor_number = clampi(int(summary.get("floor",ui.game.run.get("floor",1))),1,3)
	var background = TextureRect.new()
	background.texture = load("res://assets/cinematics/%s.png" % ["crypt","forest","volcano"][floor_number-1])
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color(0.45,0.45,0.48)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background,0,0,1280,720)
	ui.panel(140,42,1000,562).name = "RunSummaryFrame"
	center(ui,"EL CICLO CONTINÚA" if won else "EL CICLO RECOMIENZA",62,30,18,ui.GOLD)
	center(ui,"El camino queda atrás" if won else "El mundo los recuerda",96,70,42,ui.TEXT)
	var party_names: Array = ui.game.run.party.map(func(id): return ui.game.content.heroes[id].name)
	center(ui," + ".join(party_names),166,40,23,ui.GOLD)
	var victory_text = "Completaste los pisos de esta expedición.\nLa aventura está completa." if int(ui.game.run.get("floor_count",1)) > 1 else "Completaste %s." % ["la cripta de los ecos","el bosque de las raíces","la fortaleza del último fuego"][floor_number-1]
	var defeat_text = "Decidiste volver al campamento.\nLos contratos se renuevan para el próximo intento." if summary.get("abandoned",false) else "Ambos compañeros han caído.\nOtra pareja. Otro mazo. Una nueva oportunidad."
	center(ui,victory_text if won else defeat_text,208,76,22,ui.MUTED)
	center(ui,"Piso %d · Retorno %d · %s" % [floor_number,summary.get("difficulty",0),{"normal":"Sin condición","tainted":"Profanada","dangerous":"Expedición peligrosa"}.get(summary.get("variant","normal"),"Sin condición")],286,30,17,ui.MUTED)
	var stats: Dictionary = summary.get("statistics",{})
	var metrics = [["Combates",stats.get("battles",0)],["Élites",stats.get("elites",0)],["Guardianes",stats.get("bosses",0)],["Almas obtenidas",stats.get("souls",0)]]
	for i in range(metrics.size()):
		var tile = ui.panel(174+i*236,324,224,88)
		ui.label_at(str(metrics[i][1]),12,4,200,48,30,ui.GOLD,tile).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ui.label_at(metrics[i][0],12,54,200,28,17,ui.MUTED,tile).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center(ui,"%d salas · %d cartas al final · %d daño recibido" % [int(ui.game.run.get("rooms_completed",0))+ui.game.run.visited.size(),ui.game.run.get("summary_cards",ui.game.run.deck.size()),stats.get("damage_taken",0)],421,34,19,ui.TEXT)
	var scroll = ScrollContainer.new()
	scroll.name = "RunSummaryDetails"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui.rect(scroll,174,467,932,112)
	var details = VBoxContainer.new()
	details.custom_minimum_size.x = 908
	details.add_theme_constant_override("separation",8)
	scroll.add_child(details)
	var relic_names: Array[String] = []
	for id in summary.get("relics",[]):
		if ui.game.content.relics.has(id): relic_names.append(ui.game.content.relics[id].name)
	detail(ui,details,"Reliquias (%d): " % relic_names.size() + (", ".join(relic_names) if not relic_names.is_empty() else "ninguna"))
	detail(ui,details,"Ecos desbloqueados: " + ", ".join(ui.game.run.new_unlocks) if not ui.game.run.new_unlocks.is_empty() else "Tus desbloqueos anteriores se conservan.")
	var contract: Dictionary = ui.game.run.get("contract_result",{})
	if not contract.is_empty():
		detail(ui,details,("%s · +%d almas" % [contract.name,contract.reward]) if contract.complete else (contract.name+" · no completado. Tres nuevas ofertas disponibles."))
	ui.button("Volver al campamento",322,622,310,56,ui.open_base_camp)
	ui.button("Colección de ecos",650,622,310,56,ui.open_collection)

static func center(ui: Control, text: String, y: float, height: float, font_size: int, color: Color) -> void:
	ui.label_at(text,174,y,932,height,font_size,color).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

static func detail(ui: Control, parent: Control, text: String) -> void:
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",roundi(17*preload("res://src/presentation/preferences.gd").text_scale()))
	label.add_theme_color_override("font_color",ui.GOLD)
	parent.add_child(label)
