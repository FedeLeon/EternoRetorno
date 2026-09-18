extends RefCounted
# Presentation only. Prices, purchases and persistence belong to rules/Game.
static func build(ui: Control, content: RefCounted, profile: Dictionary, selected: String, settings: Dictionary, levels: Dictionary, actions: Dictionary) -> void:
	var background = TextureRect.new()
	background.texture = preload("res://assets/forge/interior.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720)
	preload("res://src/ui/components/preparation_header.gd").build(ui, "La Herrería · Acero que perdura", actions.menu, profile.souls)
	var ids = content.heroes.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var button = ui.button(content.heroes[id].name, 446, 116 + i * 80, 166, 62, func(): actions.category.call(id))
		button.name = "ForgeHero_" + id
		if id == selected:
			button.add_theme_color_override("font_color", ui.GOLD)
	ui.panel(628, 102, 626, 536)
	var title = ui.label_at(content.heroes[selected].name, 646, 112, 390, 40, 27, ui.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("Mejoras permanentes. Se aplican al iniciar una nueva aventura.", 650, 156, 380, 58, 18, ui.TEXT)
	var preview = ui.art(selected, 1070, 100, 124, 124, null, levels)
	preview.name = "ForgePreview"
	preview.tooltip_text = "Equipo actual"
	for i in range(2):
		var track = "weapon" if i == 0 else "armor"
		var level = int(levels[track])
		var amount = int(settings.strength_per_level if i == 0 else settings.block_per_level)
		var y = 230 + i * 178
		ui.label_at("%s · Nivel %d / 3" % ["Arma" if i == 0 else "Armadura", level], 656, y, 530, 34, 24, ui.GOLD)
		ui.label_at("+%d %s" % [level * amount, "de fuerza por golpe" if i == 0 else "de bloqueo en cartas defensivas"], 656, y + 36, 536, 32, 19, ui.TEXT)
		var price = int(settings.prices[level]) if level < 3 else 0
		var caption = "Mejora máxima" if level == 3 else "Mejorar (+%d) · %d almas" % [amount, price]
		var buy = ui.button(caption, 656, y + 83, 562, 54, func(): actions.buy.call(track, level + 1), level < 3 and profile.souls >= price)
		buy.name = "Upgrade_" + track
	ui.button("Volver al campamento", 846, 656, 380, 48, actions.back)
