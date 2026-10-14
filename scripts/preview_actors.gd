extends SceneTree
const Enemy = preload("res://src/enemy_sprite.gd")
var actors: Array = []
func _initialize() -> void:
	call_deferred("preview")

func label_at(text: String, x: float, y: float, width: float, font_size: int = 18) -> void:
	var label = Label.new()
	label.text = text
	label.position = Vector2(x, y)
	label.size = Vector2(width, 40)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	root.add_child(label)

func preview() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	var background = ColorRect.new()
	background.color = Color("161e2b")
	background.size = Vector2(1280, 720)
	root.add_child(background)
	label_at("ETERNO RETORNO · Actores sketchbook", 0, 22, 1280, 26)
	label_at("Mismo tamaño en juego · fuentes originales con más detalle", 0, 61, 1280)
	var heroes = ["warrior", "guardian", "rogue", "mage"]
	var names = ["Carpintero", "Constructora", "Boticario", "Profesora"]
	for i in range(heroes.size()):
		var hero = load("res://src/" + heroes[i] + "_sprite.gd").new()
		hero.position = Vector2(110 + i * 275, 117)
		hero.size = Vector2(144, 136)
		hero.pivot_offset = Vector2(72, 136)
		hero.scale = Vector2.ONE * 1.25
		root.add_child(hero)
		actors.append(hero)
		label_at(names[i], i * 208, 267, 208)
	var index = 0
	label_at("Primera cripta · 8 cuadros por ciclo de movimiento", 0, 338, 1280, 23)
	for id in Enemy.entries():
		if int(Enemy.entries()[id].floor) != 1:
			continue
		var enemy = Enemy.new()
		enemy.visual_id = id
		enemy.position = Vector2(42 + index * 208, 431)
		enemy.size = Vector2(128, 132)
		enemy.pivot_offset = Vector2(64, 124)
		enemy.scale = Vector2.ONE * 1.25
		root.add_child(enemy)
		actors.append(enemy)
		label_at(Enemy.entries()[id].name, index * 208, 579, 208, 17)
		index += 1
	label_at("Reposo, movimiento y ataque · vista de desarrollo", 0, 655, 1280, 17)
	if DisplayServer.get_name() == "headless":
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("user://actor-preview")
	for frame in range(32):
		if frame == 16:
			for actor in actors:
				actor.play_once("attack")
		await create_timer(0.125).timeout
		await RenderingServer.frame_post_draw
		var capture = root.get_texture().get_image()
		capture.save_png("user://actor-preview/frame-%03d.png" % frame)
		if frame == 0:
			capture.save_png(preload("res://tests/artifacts.gd").path("quality/actors.png"))
	print(ProjectSettings.globalize_path("user://actor-preview"))
	quit()
