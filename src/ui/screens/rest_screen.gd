extends Control
# Presentation snapshot only. Rest resolution and persistence stay in Game.
signal heal_requested
signal upgrade_requested
signal menu_requested

const ButtonSkin = preload("res://src/ui/components/button_skin.gd")
const HealthBar = preload("res://src/ui/components/health_bar.gd")
var heroes: Array = []
var can_upgrade = true
var background_path = "res://assets/rest/background.png"

func place(node: Control, area: Rect2, parent: Node = self) -> void:
	node.position = area.position
	node.size = area.size
	parent.add_child(node)

func picture(path: String, area: Rect2, parent: Node = self) -> TextureRect:
	var image = TextureRect.new()
	image.texture = load(path)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(image, area, parent)
	return image

func label(text: String, area: Rect2, font_size: int, parent: Node = self) -> Label:
	var text_view = Label.new()
	text_view.text = text
	text_view.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_view.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_view.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_view.add_theme_font_size_override("font_size", font_size)
	text_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(text_view, area, parent)
	return text_view

func _ready() -> void:
	name = "RestScreen"
	var scenery = picture(background_path, Rect2(0, 0, 1280, 720))
	scenery.stretch_mode = TextureRect.STRETCH_SCALE
	scenery.self_modulate = preload("res://src/ui/components/battle_background.gd").SCENERY_TINT
	var header = Panel.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_stylebox_override("panel", ButtonSkin.style("header_frame"))
	place(header, Rect2(0, 0, 1280, 70))
	label("Descanso · Una brasa en la oscuridad", Rect2(140, 10, 990, 48), 28).add_theme_color_override("font_color", Color("e5c48d"))
	var menu = Button.new()
	menu.name = "Menu"
	menu.text = "Menú"
	ButtonSkin.decorate(menu, "wood_menu")
	menu.pressed.connect(func(): menu_requested.emit())
	place(menu, Rect2(1134, 10, 124, 48))
	var fire = preload("res://src/campfire.gd").new()
	fire.name = "RestCampfire"
	fire.embers_only = true
	fire.position = Vector2(640,444)
	fire.scale = Vector2(1.25,1.25) # Full-size brazier between the seated heroes.
	add_child(fire)
	for i in range(heroes.size()):
		var hero: Dictionary = heroes[i]
		var left = 220.0 if i == 0 else 800.0
		var actor = picture("res://assets/rest/%s.png" % hero.id, Rect2(left, 208, 260, 252))
		actor.name = "Hero%d" % i
		actor.flip_h = i == 1
		preload("res://src/presentation/seated_hero_art.gd").fit(actor, hero.id, Rect2(left, 224, 260, 236))
		preload("res://src/presentation/firelight.gd").attach(actor, i * 0.6)
		if hero.hp <= 0: actor.modulate = Color(0.55, 0.55, 0.6)
		var bar = HealthBar.new()
		bar.name = "Health%d" % i
		bar.set_health(hero.hp, hero.max_hp)
		place(bar, Rect2(left + 14, 196, 232, 28))
	label("Elegí cómo aprovechar este descanso", Rect2(280, 450, 720, 28), 20)
	choice("Heal", "heal", "Recuperar vida", "Recuperá el 30 % de la vida máxima de cada héroe.", Rect2(340, 486, 280, 222), func(): heal_requested.emit())
	var upgrade = choice("Upgrade", "upgrade", "Mejorar una carta", "Elegí una carta del mazo y potenciá su efecto.", Rect2(660, 486, 280, 222), func(): upgrade_requested.emit())
	upgrade.disabled = not can_upgrade
	if not can_upgrade:
		upgrade.tooltip_text = "Todas las cartas del mazo ya están mejoradas."
		upgrade.modulate = Color(0.55, 0.55, 0.55)

func choice(id: String, art: String, title: String, description: String, area: Rect2, action: Callable) -> Button:
	var button = Button.new()
	button.name = id
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style = preload("res://src/ui/components/dark_skin.gd").focus() if state == "focus" else preload("res://src/ui/components/button_skin.gd").state_style("wood_button",state)
		button.add_theme_stylebox_override(state, style)
	button.pressed.connect(action)
	place(button, area)
	var illustration = picture("res://assets/rest/%s.png" % art, Rect2(10, 10, 260, 112), button)
	illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if art == "upgrade" else TextureRect.STRETCH_KEEP_ASPECT_COVERED
	label(title, Rect2(12, 125, 256, 32), 22, button).add_theme_color_override("font_color", Color("e5c48d"))
	label(description, Rect2(16, 161, 248, 49), 17, button)
	return button
