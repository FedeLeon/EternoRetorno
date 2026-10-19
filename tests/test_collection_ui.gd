extends SceneTree
const Game = preload("res://src/game.gd")
var checks = 0
var failures = 0
var app: Control
func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(caption)
func _initialize() -> void:
	call_deferred("run_tests")
func shot(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("collection/" + name + ".png"))
func click(button: Button) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = button.get_global_rect().get_center()
		root.push_input(event)
	await process_frame
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-collection-ui.save", false)
	root.add_child(app)
	app.open_collection()
	await create_timer(0.3).timeout
	var screen = app.layer.get_node("CollectionScreen")
	var before = app.game.profile.duplicate(true)
	check(app.layer.get_node("HeaderBack").icon != null, "Home has back arrow asset")
	check(screen.find_children("*", "Button", true, false).all(func(b): return b.text != "Menú"), "no menu button in collection")
	check(screen.find_children("Achievement_*", "Button", true, false).size() == 28, "active achievements present; unearned legacy hero milestones hidden")
	check(screen.find_child("AchievementTotals", true, false).text.begins_with("0 / %d logros" % app.game.Achievements.catalog().size()), "summary uses the actual active achievement count")
	for tab in ["AchievementsTab", "UnlocksTab", "HistoryTab"]:
		check(screen.get_node(tab).icon != null, "category has its own asset: " + tab)
	var signatures: Dictionary = {}
	for entry in app.game.Achievements.catalog():
		var icon = load("res://assets/collection/icons/%s.png" % entry.id)
		check(icon is Texture2D and icon.get_width() == 512 and icon.get_height() == 512, "achievement illustration retains detail resolution: " + entry.id)
		signatures[hash(icon.get_image().get_data())] = true
	check(signatures.size() == 28, "all achievement drawings are distinct")
	await shot("achievements")
	var secret = screen.find_child("Achievement_oathbound", true, false)
	secret.pressed.emit()
	var detail = screen.find_child("AchievementDetail", true, false)
	var labels = detail.find_children("*", "Label", true, false)
	check(labels.any(func(l): return l.text == "Eco desconocido"), "locked secret conceals title")
	check(labels.all(func(l): return "Guerrero" not in l.text and "Guardiana" not in l.text and "/" not in l.text), "secret panel reveals no conditions")
	check(detail.find_children("*", "TextureRect", true, false)[0].texture.resource_path.ends_with("secret.png"), "secret illustration conceals undiscovered artwork")
	await click(screen.get_node("UnlocksTab"))
	check(screen.find_children("Achievement_*", "Button", true, false).is_empty(), "tabs replace content")
	check(screen.find_children("*", "Label", true, false).any(func(l): return l.text == "Reloj sin arena"), "legacy relic unlock retained")
	check(screen.snapshot.unlocks.any(func(e): return e.name == "Reloj sin arena" and e.icon.ends_with("unlocks/hourglass.png")), "hourglass uses a dedicated drawing")
	await shot("unlocks")
	await click(screen.get_node("HistoryTab"))
	check(screen.find_children("*", "Label", true, false).any(func(l): return "Tu historia" in l.text), "empty history explained")
	check(app.game.profile == before, "view and tab changes do not mutate profile")
	await click(app.layer.get_node("HeaderBack"))
	check(app.screen == "home", "Home button navigates to title screen")
	app.game.profile.victories = 1
	app.game.profile.attempts = 3
	app.game.profile.history = [{"won": true, "party": ["warrior", "guardian"], "rooms": 40}, {"won": false, "party": ["rogue", "mage"], "rooms": 5}]
	app.game.profile.boss_relics=["crypt_blood"]
	app.game.checkpoint()
	app.open_collection()
	await create_timer(0.2).timeout
	screen = app.layer.get_node("CollectionScreen")
	await click(screen.get_node("UnlocksTab"))
	var relic_name:String=app.game.content.relics.crypt_blood.name
	check(screen.find_children("*", "Label", true, false).any(func(l):return l.text==relic_name),"boss relic discovery is visible in collection")
	check(screen.find_children("*", "Label", true, false).any(func(l):return l.text.begins_with("DESCUBIERTA")),"discovery explains current-run effect without granting future power")
	await click(screen.get_node("AchievementsTab"))
	screen.find_child("Achievement_warrior_victory", true, false).pressed.emit()
	await shot("unlocked")
	await click(screen.get_node("HistoryTab"))
	check(screen.find_children("*", "Label", true, false).any(func(l): return l.text == "Carpintero + Constructora"), "history uses current profession titles")
	for result in ["victory", "return"]:
		check(screen.find_children("*", "TextureRect", true, false).any(func(n): return n.texture != null and n.texture.resource_path.ends_with(result + ".svg")), "history outcome has a drawing: " + result)
	await shot("history")
	await icon_gallery()
	app.queue_free();await process_frame;await create_timer(0.15).timeout
	print("COLLECTION UI: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)

func icon_gallery() -> void:
	if DisplayServer.get_name() == "headless": return
	var page = Control.new()
	root.add_child(page)
	var bg = ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color("182333")
	page.add_child(bg)
	var paths: Array = []
	for entry in app.game.Achievements.catalog(): paths.append([entry.id, "res://assets/collection/icons/%s.png" % entry.id])
	paths.append(["secret", "res://assets/collection/secret.png"])
	for id in ["achievements", "unlocks", "history", "hourglass", "victory", "return"]: paths.append([id, "res://assets/collection/ui/%s.svg" % id])
	for i in range(paths.size()):
		var picture = TextureRect.new()
		picture.texture = load(paths[i][1])
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.position = Vector2(60 + (i % 7) * 176, 8 + (i / 7) * 140)
		picture.size = Vector2(96, 96)
		page.add_child(picture)
		var label = Label.new()
		label.text = paths[i][0]
		label.position = picture.position + Vector2(-36, 98)
		label.size = Vector2(168, 30)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 14)
		page.add_child(label)
	await shot("icon-gallery")
	page.queue_free()
