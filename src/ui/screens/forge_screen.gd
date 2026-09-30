extends RefCounted
# Presentation only. Prices, purchases and persistence belong to rules/Game.
static func build(ui: Control, content: RefCounted, profile: Dictionary, selected: String, settings: Dictionary, levels: Dictionary, actions: Dictionary) -> void:
	var background = TextureRect.new()
	background.texture = preload("res://assets/forge/interior.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720)
	preload("res://src/ui/components/attendant_dialogue.gd").attach(ui, "forge")
	preload("res://src/ui/components/preparation_header.gd").build(ui, "La Herrería · Acero que perdura", actions.back, profile.souls, "Campamento")
	if selected == "":
		preload("res://src/ui/components/building_hero_picker.gd").build(ui, content.heroes, "Elegí un héroe para mejorar su equipo", "ForgeHero_", actions.category, true)
		return
	ui.panel(628, 102, 626, 536)
	var back = ui.button("Volver a héroes", 1046, 108, 192, 40, func(): actions.category.call(""))
	back.name = "BackToHeroes"
	back.add_theme_font_size_override("font_size", 16)
	var title = ui.label_at(content.heroes[selected].name, 646, 112, 390, 40, 27, ui.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("Mejoras permanentes. Se aplican al iniciar una nueva aventura.", 650, 156, 380, 58, 18, ui.TEXT)
	var preview = ui.art(selected, 1054, 142, 155, 155, null, levels)
	preview.name = "ForgePreview"
	preview.tooltip_text = "Equipo actual"
	for i in range(2):
		var track = "weapon" if i == 0 else "armor"
		var level = int(levels[track])
		var amount = int(settings.strength_per_level if i == 0 else settings.block_per_level)
		var y = 300 + i * 178
		ui.label_at("%s · Nivel %d / 3" % ["Arma" if i == 0 else "Armadura", level], 656, y, 530, 34, 24, ui.GOLD)
		ui.label_at("+%d %s" % [level * amount, "de fuerza por golpe" if i == 0 else "de bloqueo en cartas defensivas"], 656, y + 36, 536, 32, 19, ui.TEXT)
		var price = int(settings.prices[level]) if level < 3 else 0
		var caption = "Mejora máxima" if level == 3 else "Mejorar (+%d) · %d almas" % [amount, price]
		var buy = ui.button(caption, 656, y + 83, 562, 54, func(): actions.buy.call(track, level + 1), level < 3 and profile.souls >= price)
		buy.name = "Upgrade_" + track
