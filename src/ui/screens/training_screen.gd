extends RefCounted
static func build(ui: Control) -> void:
	var bg = TextureRect.new()
	bg.texture = preload("res://assets/combat_depth/training.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(bg, 0, 0, 1280, 720)
	preload("res://src/ui/components/preparation_header.gd").build(ui,"Patio de entrenamiento",ui.open_base_camp,-1,"Campamento")
	ui.panel(36,94,1208,38)
	ui.label_at("Elegí una pareja. Probá cartas, equipo y rivales sin gastar celdas ni alterar la aventura.",54,95,1172,36,18,ui.TEXT)
	var chosen: Array = []
	var buttons: Array[Button] = []
	var weapon = OptionButton.new()
	var armor = OptionButton.new()
	for level in range(4):
		weapon.add_item("Armas · nivel %d" % level)
		armor.add_item("Armaduras · nivel %d" % level)
	ui.rect(weapon, 60, 280, 300, 48)
	ui.rect(armor, 60, 350, 300, 48)
	ui.button("Configurar rivales",60,410,300,44,func(): preload("res://src/ui/screens/training_config_dialog.gd").open(ui))
	var start = ui.button("Entrenar", 60, 470, 300, 58, func(): preload("res://src/ui/training_navigation.gd").start(ui, chosen, weapon.selected, armor.selected), false)
	start.disabled = true
	var ids = preload("res://src/rules/hero_roster.gd").ids(ui.game.content.heroes)
	preload("res://src/ui/components/building_hero_picker.gd").build(ui, ui.game.content.heroes, "Elegí dos héroes para entrenar", "TrainingHero_", func(id):
		if id in chosen: chosen.erase(id)
		elif chosen.size() < 2: chosen.append(id)
		for j in range(buttons.size()): buttons[j].modulate = Color(1.3,1.2,1.0) if ids[j] in chosen else Color.WHITE
		start.disabled = chosen.size() != 2, true)
	for id in ids: buttons.append(ui.layer.get_node("TrainingHero_" + id))
