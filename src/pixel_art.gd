extends Control
# Original code-native pixel art; all silhouettes use a small, integer grid.
var kind = "warrior"
var tint = Color("c66d58")
var scene_art = false
var clock_time = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	clock_time += delta
	if scene_art:
		queue_redraw()

func block(x: float, y: float, w: float, h: float, color: Color) -> void:
	draw_rect(Rect2(x, y, w, h), color)

func _draw() -> void:
	if scene_art:
		_draw_scene()
		return
	var scale_factor = minf(size.x / 40.0, size.y / 48.0)
	draw_set_transform(Vector2((size.x - 40 * scale_factor) / 2, size.y - 48 * scale_factor), 0, Vector2.ONE * scale_factor)
	var dark = Color("171926")
	var steel = Color("8994a6")
	var light = tint.lightened(0.25)
	block(7, 44, 28, 3, Color(0.0, 0.0, 0.0, 0.4))
	if kind == "slime":
		block(7, 31, 28, 12, tint.darkened(0.3))
		block(10, 26, 22, 15, tint)
		block(14, 23, 15, 9, light)
		block(14, 32, 3, 3, dark)
		block(25, 32, 3, 3, dark)
		block(17, 40, 6, 2, tint.darkened(0.4))
	elif kind == "rat":
		block(9, 30, 24, 12, tint.darkened(0.2))
		block(5, 32, 16, 8, tint)
		block(8, 26, 6, 8, tint)
		block(23, 26, 7, 8, tint)
		block(8, 34, 2, 2, Color("ffbf78"))
		block(5, 39, 3, 2, Color("eadbc0"))
		block(13, 41, 4, 4, dark)
		block(28, 41, 4, 4, dark)
		block(32, 33, 7, 3, tint)
		block(37, 27, 2, 8, tint)
	else:
		var robe = kind in ["mage", "cleric", "cultist", "boss"]
		block(13, 34, 6, 11, Color("303342"))
		block(23, 34, 6, 11, Color("303342"))
		block(11, 43, 8, 3, dark)
		block(23, 43, 9, 3, dark)
		block(11, 18, 21, 19, tint.darkened(0.35))
		block(13, 18, 16, 17, tint)
		block(13, 19, 4, 13, light)
		if robe:
			block(9, 33, 25, 9, tint.darkened(0.2))
			block(15, 34, 3, 8, tint)
			block(25, 34, 3, 8, tint)
		block(14, 5, 14, 14, dark)
		block(16, 7, 12, 11, Color("c2a185"))
		block(16, 7, 12, 4, tint.darkened(0.25))
		block(16, 5, 10, 3, tint.darkened(0.4))
		block(20, 12, 2, 2, dark)
		block(26, 12, 2, 2, dark)
		block(23, 16, 4, 1, Color("8b695d"))
		block(11, 31, 21, 3, Color("4d3b35"))
		block(21, 31, 3, 3, Color("d6b56e"))
		block(7, 20, 5, 13, tint.darkened(0.15))
		block(30, 20, 5, 12, tint.darkened(0.15))
		block(8, 30, 4, 4, Color("c2a185"))
		block(30, 29, 4, 4, Color("c2a185"))
		if kind in ["warrior", "guardian", "elite", "skeleton"]:
			block(14, 4, 15, 8, steel.darkened(0.3))
			block(13, 9, 17, 3, steel)
			block(21, 10, 2, 8, steel)
			block(5, 20, 10, 3, steel)
			block(28, 20, 8, 3, steel)
			block(35, 7, 2, 26, Color("c8d1d5"))
			block(33, 27, 7, 2, Color("d6b56e"))
			if kind in ["guardian", "elite"]:
				block(2, 25, 13, 13, steel.darkened(0.3))
				block(4, 27, 9, 12, tint)
				block(8, 28, 2, 11, Color("d6b56e"))
			if kind == "skeleton":
				block(17, 10, 11, 8, Color("e0d4b7"))
				block(18, 12, 3, 3, dark)
				block(25, 12, 3, 3, dark)
		elif kind in ["mage", "cleric", "cultist", "boss"]:
			block(35, 11, 2, 32, Color("8c745d"))
			block(33, 8, 6, 6, Color("c6a673"))
			block(34, 5, 4, 7, light)
			if kind == "mage":
				block(12, 6, 18, 3, tint)
				block(17, 1, 9, 6, tint)
			if kind in ["cultist", "boss"]:
				block(16, 9, 12, 9, dark)
				block(19, 12, 2, 2, Color("f3a879"))
				block(25, 12, 2, 2, Color("f3a879"))
			if kind == "boss":
				block(11, 0, 3, 8, Color("e7c189"))
				block(29, 0, 3, 8, Color("e7c189"))
				block(12, 4, 20, 3, Color("e7c189"))
		elif kind == "ranger":
			block(14, 5, 17, 5, tint.darkened(0.3))
			block(17, 3, 9, 5, tint.darkened(0.3))
			block(36, 14, 2, 23, Color("b59362"))
			block(33, 10, 3, 5, Color("b59362"))
			block(33, 37, 3, 5, Color("b59362"))
			block(33, 15, 1, 22, Color("dad0b2"))
		else:
			block(14, 3, 14, 7, tint.darkened(0.4))
			block(16, 15, 12, 4, tint.darkened(0.4))
			block(34, 22, 2, 11, Color("c8d1d5"))
			block(32, 30, 6, 2, Color("d6b56e"))
	draw_set_transform(Vector2.ZERO)

func _draw_scene() -> void:
	block(0, 0, size.x, size.y, Color("0c0f18"))
	for row in range(int(size.y / 42) + 1):
		for col in range(int(size.x / 86) + 1):
			var v = (row * 17 + col * 13) % 5
			var color = Color("141924").lightened(v * 0.007)
			block(col * 86 - (42 if row % 2 else 0), row * 42, 82, 38, color)
	# Three vaulted, stepped arches; silhouettes remain deliberately low contrast.
	for x in [size.x * 0.15, size.x * 0.5, size.x * 0.85]:
		block(x - 72, 108, 144, size.y - 160, Color("080b12"))
		block(x - 58, 82, 116, 28, Color("080b12"))
		block(x - 36, 64, 72, 20, Color("080b12"))
		for side in [-1, 1]:
			block(x + side * 80 - 8, 112, 16, size.y - 150, Color("222631"))
			for y in range(122, int(size.y - 44), 36):
				block(x + side * 80 - 9, y, 18, 3, Color("323441"))
	block(0, size.y - 60, size.x, 60, Color("171b25"))
	for x in range(0, int(size.x), 96):
		block(x, size.y - 34, 91, 2, Color("30313a"))
	for x in [size.x * 0.3, size.x * 0.7]:
		block(x - 5, 168, 10, 31, Color("665048"))
		block(x - 9, 165, 18, 5, Color("908078"))
		var flicker = int(clock_time * 6) % 3
		block(x - 8, 143 - flicker * 3, 16, 22 + flicker * 3, Color("be613c"))
		block(x - 4, 148 - flicker * 2, 8, 15 + flicker * 2, Color("efb764"))
		block(x - 2, 156, 4, 9, Color("ffe0a0"))
