extends RefCounted
# Presentation only. Eligibility, prices, ownership and effects come from rules.
static func build(ui: Control, snapshot: Dictionary, actions: Dictionary) -> void:
	var background = TextureRect.new()
	background.texture = load("res://assets/church/interior.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720)
	preload("res://src/ui/components/preparation_header.gd").build(ui, "La Iglesia · Elegí tu camino", actions.back, snapshot.souls, "Campamento")
	if snapshot.hero == "":
		var heading_frame = Panel.new()
		heading_frame.name = "ChurchHeadingFrame"
		heading_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		heading_frame.add_theme_stylebox_override("panel", preload("res://src/ui/components/dark_skin.gd").frame(true))
		ui.rect(heading_frame, 180, 114, 920, 72)
		preload("res://src/ui/components/building_hero_picker.gd").build(ui, snapshot.heroes, "Una victoria abre nuevos caminos para cada héroe", "ChurchHero_", actions.hero)
		return
	ui.button("Volver a héroes", 32, 92, 248, 48, func(): actions.hero.call("")).name = "BackToHeroes"
	var specialization_heading = Panel.new()
	specialization_heading.name = "SpecializationHeadingFrame"
	specialization_heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	specialization_heading.add_theme_stylebox_override("panel", preload("res://src/ui/components/dark_skin.gd").dialog())
	ui.rect(specialization_heading, 290, 92, 800, 48)
	ui.label_at(snapshot.heroes[snapshot.hero].name + " · Especializaciones", 290, 92, 800, 48, 27, ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for i in range(snapshot.options.size()):
		var spec: Dictionary = snapshot.options[i]
		var active = spec.id == snapshot.active
		var body = preload("res://src/ui/components/camp_offer_card.gd").build(ui, ui.layer, Rect2(206 + i * 446, 148, 422, 488), "res://assets/church/%s.png" % spec.art, spec.name, spec.description, true)
		body.name = "Specialization_" + spec.id
		if active: body.modulate = Color(1.12, 1.07, 0.96)
		var status = "Activa para próximas aventuras" if active else ("Aprendida" if spec.owned else ("Costo: %d almas" % spec.cost if snapshot.eligible else "Requiere ganar una aventura con este héroe"))
		ui.label_at(status, 18, 380, 386, 44, 18, ui.GOLD, body).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var caption = "Activa" if active else ("Activar" if spec.owned else "Aprender · %d almas" % spec.cost)
		var enabled = not active and (spec.owned or (snapshot.eligible and snapshot.souls >= spec.cost))
		var button = ui.button(caption, 22, 430, 378, 48, func(): actions.activate.call(spec.id) if spec.owned else actions.buy.call(spec.id), enabled, body)
		button.name = "LearnSpecialization"
	ui.label_at("Una activa por héroe. Aprender cuesta almas una sola vez; cambiar entre aprendidas es gratis.\nLos cambios se aplican al iniciar una aventura nueva.", 220, 646, 840, 56, 18, ui.TEXT).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
