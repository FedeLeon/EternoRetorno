extends RefCounted
static func build(ui: Control) -> void:
	var selected = [-1]
	var action: String = ui.game.run.card_event
	ui.header("Elegí el destino de una carta", "Retirar" if action == "remove" else ("Transformar: carta de su héroe, coste 0–1 y mejorada" if action == "transform" else "Intercambiar por otra carta de su héroe de coste 0–1"))
	var confirm = ui.button("Confirmar", 920, 645, 320, 55, func():
		if ui.game.modify_event_card(selected[0]): ui.audio.play_sfx("upgrade"); ui.continue_run(), false)
	confirm.name = "ConfirmEventCard"
	var scroll = ScrollContainer.new()
	ui.rect(scroll, 40, 145, 1200, 485)
	var body = Control.new()
	body.custom_minimum_size = Vector2(1170, ceili(ui.game.run.deck.size() / 4.0) * 365)
	scroll.add_child(body)
	for i in range(ui.game.run.deck.size()):
		var card = ui.card_panel(ui.game.run.deck[i], (i % 4) * 290, (i / 4) * 365, 220, 350, func():
			selected[0] = i
			var owner = ui.game.content.cards[ui.game.run.deck[i].id].owner
			confirm.disabled = action == "remove" and (ui.game.run.deck.size() <= 12 or ui.game.run.deck.filter(func(instance): return ui.game.content.cards[instance.id].owner == owner).size() <= 4)
			for child in body.get_children(): child.modulate = Color.WHITE if child.get_meta("deck_index", -1) == i else Color(0.65,0.65,0.65), false, true, body, true)
		card.set_meta("deck_index", i)
	ui.button("Continuar sin cambiar", 40, 645, 340, 55, func(): ui.act(func(): ui.game.modify_event_card(-1)))
