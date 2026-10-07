extends RefCounted
static func build(ui: Control) -> void:
	var bg = TextureRect.new()
	bg.texture = preload("res://assets/combat_depth/training.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(bg, 0, 0, 1280, 720)
	ui.panel(20, 12, 1240, 116)
	ui.header("Patio de entrenamiento", "Elegí una pareja. Probá todas sus cartas y niveles de equipo sin gastar almas ni alterar la aventura.")
	for child in ui.layer.get_children():
		if child is Button and child.text == "Menú": child.hide()
	ui.button("Campamento", 1020, 22, 220, 42, func(): ui.open_base_camp())
	var chosen: Array = []
	var buttons: Array[Button] = []
	var weapon = OptionButton.new()
	var armor = OptionButton.new()
	for level in range(4):
		weapon.add_item("Armas · nivel %d" % level)
		armor.add_item("Armaduras · nivel %d" % level)
	ui.rect(weapon, 60, 280, 300, 48)
	ui.rect(armor, 60, 350, 300, 48)
	var start = ui.button("Entrenar", 60, 470, 300, 58, func(): preload("res://src/ui/training_navigation.gd").start(ui, chosen, weapon.selected, armor.selected), false)
	start.disabled = true
	var ids = ui.game.content.heroes.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var button = preload("res://src/ui/components/refuge_portrait.gd").build(ui, ui.layer, id, ui.game.content.heroes[id].name, Vector2(688 + (i % 2) * 266, 172 + (i / 2) * 174), func():
			if id in chosen: chosen.erase(id)
			elif chosen.size() < 2: chosen.append(id)
			for j in range(buttons.size()): buttons[j].modulate = Color(1.3,1.2,1.0) if ids[j] in chosen else Color.WHITE
			start.disabled = chosen.size() != 2, true)
		buttons.append(button)
