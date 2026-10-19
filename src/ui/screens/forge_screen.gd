extends RefCounted
# Presentation only. Prices, purchases and persistence belong to rules/Game.
static func build(ui: Control, content: RefCounted, profile: Dictionary, selected: String, settings: Dictionary, materials: Dictionary, levels: Dictionary, actions: Dictionary) -> void:
	var background = TextureRect.new()
	background.texture = preload("res://assets/forge/interior.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720)
	preload("res://src/ui/components/attendant_dialogue.gd").attach(ui, "forge")
	preload("res://src/ui/components/preparation_header.gd").build(ui, "El Taller · Herramientas para resistir", actions.back, profile.souls, "Campamento")
	if selected == "":
		preload("res://src/ui/components/building_hero_picker.gd").build(ui, content.heroes, "Elegí un héroe para mejorar su equipo", "ForgeHero_", actions.category, true)
		return
	ui.panel(628, 102, 626, 602).name = "ForgeDetail"
	var title = ui.label_at(content.heroes[selected].name + " · Equipo", 646, 110, 590, 38, 27, ui.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("Mejoras permanentes para la próxima aventura.", 650, 152, 578, 40, 18, ui.TEXT)
	for i in range(2):
		var track = "weapon" if i == 0 else "armor"
		var level = int(levels[track])
		var amount = int(settings.strength_per_level if i == 0 else settings.block_per_level)
		var card = ui.panel(646 + i * 300, 202, 290, 310)
		card.name = "Equipment_" + track
		var heading = ui.label_at("%s · %d / 3" % ["Arma" if i == 0 else "Armadura", level], 14, 8, 262, 32, 22, ui.GOLD, card)
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var picture = TextureRect.new()
		picture.name = "EquipmentArt"
		picture.texture = load("res://assets/forge/badges/%s_%s_%d.png" % [selected, track, mini(3, level + 1)])
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(picture, 65, 44, 160, 128, card)
		var benefit = "fuerza por golpe" if i == 0 else "bloqueo defensivo"
		var description = "Actual: +%d %s" % [level * amount, benefit]
		if level < 3: description += "\nSiguiente: +%d %s" % [(level + 1) * amount, benefit]
		var detail = ui.label_at(description, 14, 174, 262, 70, 18, ui.TEXT, card)
		detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var price = int(settings.alloy_prices[level]) if level < 3 else 0
		var caption = "Mejora máxima" if level == 3 else "Nivel %d · %d aleación" % [level + 1, price]
		var buy = ui.button(caption, 14, 252, 262, 44, func(): actions.buy.call(track, level + 1), level < 3 and materials.alloy >= price, card)
		buy.name = "Upgrade_" + track
		buy.add_theme_font_size_override("font_size", 18)
	preload("res://src/ui/components/forge_material_display.gd").stock(ui, materials, actions.smelt, Rect2(646, 526, 590, 172))
