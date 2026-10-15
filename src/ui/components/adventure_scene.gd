extends Control
# Shared adventure snapshot and visual helpers; no rules or save writes.
signal room_requested(id: int)
signal deck_requested
signal menu_requested
signal map_requested
signal descend_requested

const Dungeon = preload("res://src/dungeon.gd")
const GOLD = Color("75c7c8")
var floor_number = 1
var map_open = false
var paths_available = false
var nodes: Array = []
var available: Array = []
var visited: Array = []
var current = -1
var heroes: Array = []
var relics: Array = []
var boss_defeated = false
var deck_count = 0
var run_seed = 0
var dungeon_name = "Red de mantenimiento"
var exit_caption = "Avanzar de sector"

func place(node: Control, area: Rect2, parent: Node = self) -> void:
	node.position = area.position
	node.size = area.size
	parent.add_child(node)

func label(text: String, area: Rect2, font_size: int = 20, color: Color = Color("e9e1ee"), parent: Node = self) -> Label:
	var node = Label.new()
	node.text = text
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(node, area, parent)
	return node

func picture(texture: Texture2D, area: Rect2, parent: Node = self) -> TextureRect:
	var node = TextureRect.new()
	node.texture = texture
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(node, area, parent)
	return node

func action(text: String, area: Rect2, callback: Callable, parent: Node = self) -> Button:
	var node = Button.new()
	node.text = text
	if text in ["Avanzar de sector", "Entrar al cinturón", "Completar aventura"]:
		preload("res://src/ui/components/button_skin.gd").arrow(node)
	if text == "Menú":
		preload("res://src/ui/components/button_skin.gd").decorate(node, "wood_menu")
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(callback)
	place(node, area, parent)
	return node

