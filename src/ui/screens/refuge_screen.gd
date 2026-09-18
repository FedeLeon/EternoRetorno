extends Control
# Local draft only. Navigation controller validates and persists through Game.
signal back_requested
signal save_requested(hero: String, attacks: int)
var ui: Control
var heroes: Dictionary
var choices: Dictionary
var souls = 0
var selected = ""
var attacks = 4
var notice = ""
var body: Control

func _ready() -> void:
	name = "RefugeScreen"
	var background = TextureRect.new()
	background.texture = load("res://assets/refuge/interior.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(background, 0, 0, 1280, 720, self)
	preload("res://src/ui/components/preparation_header.gd").build(ui, "El Refugio · Prepará tu próxima aventura", func(): back_requested.emit(), souls, "Campamento")
	redraw()

func saved(value: int) -> void:
	choices[selected].attacks = value
	notice = "Guardado. Se aplicará a las próximas aventuras."
	redraw()

func redraw() -> void:
	if is_instance_valid(body):
		remove_child(body)
		body.queue_free()
	body = Control.new()
	ui.rect(body, 0, 84, 1280, 636, self)
	if selected == "":
		var heading = ui.label_at("Elegí un héroe para preparar sus 10 cartas iniciales", 80, 45, 1120, 42, 26, ui.TEXT, body)
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var ids = heroes.keys()
		for i in range(ids.size()):
			var hero = ids[i]
			preload("res://src/ui/components/refuge_portrait.gd").build(ui, body, hero, heroes[hero].name, Vector2(35 + i * 204, 172), func():
				selected = hero
				attacks = choices[hero].attacks
				notice = ""
				redraw())
		ui.label_at("El equipo cambia. Tu forma de luchar también.", 80, 550, 1120, 32, 20, ui.GOLD, body).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		return
	ui.panel(90, 10, 1100, 610, Color("67573d"), body)
	ui.label_at(heroes[selected].name + " · Mazo inicial · 10 / 10 cartas", 150, 24, 980, 38, 27, ui.GOLD, body).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("Elegí de 2 a 6 ataques; completá 8 básicas con defensas y conservá 2 de clase.", 150, 66, 980, 30, 19, ui.TEXT, body).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var original: Array = choices[selected].starter
	var ids = [original[0], original[4], original[8], original[9]]
	var counts = [attacks, 8 - attacks, 1, 1]
	for i in range(4):
		var x = 156 + i * 244
		var card = ui.card_panel({"id":ids[i], "upgraded":false}, x, 102, 230, 308, func(): pass, false, true, body, true)
		card.name = "StarterCard%d" % i
		var count = ui.label_at("%d copias" % counts[i] if counts[i] > 1 else "1 copia", x, 421, 230, 32, 23, ui.GOLD, body)
		count.name = "Copies%d" % i
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if i < 2:
			var direction = 1 if i == 0 else -1
			ui.button("-", x + 10, 458, 92, 42, func(): change(-direction), attacks - direction >= 2 and attacks - direction <= 6, body).name = "Less%d" % i
			ui.button("+", x + 128, 458, 92, 42, func(): change(direction), attacks + direction >= 2 and attacks + direction <= 6, body).name = "More%d" % i
		else:
			ui.label_at("Carta de clase", x, 464, 230, 30, 18, ui.MUTED, body).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at(notice if notice != "" else "Solo cambia el mazo de aventuras nuevas. Tu partida actual se conserva.", 150, 510, 980, 30, 18, ui.TEXT, body).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.button("Volver", 125, 554, 230, 46, go_back, true, body).name = "RefugeBack"
	ui.button("Restaurar original", 400, 554, 260, 46, func(): attacks = 4; notice = "Configuración original lista para guardar."; redraw(), attacks != 4, body).name = "RestoreStarter"
	ui.button("Guardar mazo", 750, 554, 390, 46, func(): save_requested.emit(selected, attacks), attacks != choices[selected].attacks, body).name = "SaveStarter"

func change(delta: int) -> void:
	attacks = clampi(attacks + delta, 2, 6)
	notice = "Cambios sin guardar · 10 cartas"
	redraw()

func go_back() -> void:
	if selected != "":
		selected = ""
		redraw()
	else:
		back_requested.emit()
