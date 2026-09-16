extends Control
# Procedural dungeon backdrop for map, rewards and collection screens.
var clock_time = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	clock_time += delta
	queue_redraw()

func block(x: float, y: float, w: float, h: float, color: Color) -> void:
	draw_rect(Rect2(x, y, w, h), color)

func _draw() -> void:
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
