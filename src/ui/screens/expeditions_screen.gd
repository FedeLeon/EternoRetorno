extends RefCounted
# Offers/progress are snapshots. Acceptance and rewards belong to the rules.
static func build(ui: Control, snapshot: Dictionary, actions: Dictionary) -> void:
	var background = TextureRect.new()
	background.texture = load("res://assets/expeditions/interior.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720)
	preload("res://src/ui/components/preparation_header.gd").build(ui, "Expediciones · Un propósito para el viaje", actions.back, snapshot.souls, "Campamento")
	ui.label_at("Un contrato por aventura · Las ofertas cambian al terminarla", 80, 94, 1120, 40, 24, ui.TEXT).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(snapshot.offers.size()):
		var contract: Dictionary = snapshot.offers[i]
		var chosen = contract.id == snapshot.selected
		var body = preload("res://src/ui/components/camp_offer_card.gd").build(ui, ui.layer, Rect2(70 + i * 386, 155, 368, 470), "res://assets/expeditions/contract_%s.png" % contract.art, contract.name, contract.description)
		body.name = "Contract_" + contract.id
		if chosen: body.modulate = Color(1.12, 1.07, 0.96)
		ui.label_at("Recompensa: %d almas" % contract.reward, 18, 358, 332, 30, 20, ui.GOLD, body).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var caption = "Elegido · Cancelar" if chosen else "Aceptar contrato"
		if snapshot.running: caption = "En curso: %d / %d" % [contract.progress, contract.target] if chosen else "Próxima aventura"
		var can_select = not snapshot.running and (snapshot.selected == "" or chosen)
		var button = ui.button(caption, 18, 402, 332, 48, func(): actions.select.call("" if chosen else contract.id), can_select, body)
		button.name = "AcceptContract"
	var note = "Cancelá el contrato elegido para seleccionar otro. La recompensa se entrega al finalizar la aventura."
	if snapshot.running: note = "Ya hay una aventura en curso. Finalizala para elegir otro contrato."
	elif not snapshot.last.is_empty(): note = ("Contrato completado: %s · +%d almas" % [snapshot.last.name, snapshot.last.reward]) if snapshot.last.complete else "Contrato anterior no completado: " + snapshot.last.name
	ui.label_at(note, 80, 646, 1120, 54, 19, ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
