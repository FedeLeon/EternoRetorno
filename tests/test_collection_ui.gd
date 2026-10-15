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
	check(screen.get_node("CollectionHome").icon != null, "Home has back arrow asset")
	check(screen.find_children("*", "Button", true, false).all(func(b): return b.text != "Menú"), "no menu button in collection")
	check(screen.find_children("Achievement_*", "Button", true, false).size() == 28, "active achievements present; unearned legacy hero milestones hidden")
	check(screen.find_child("AchievementTotals", true, false).text.begins_with("0 / %d logros" % app.game.Achievements.catalog().size()), "summary uses the actual active achievement count")
	for entry in app.game.Achievements.catalog():
		var icon = load("res://assets/collection/icons/%s.png" % entry.id)
		check(icon is Texture2D and icon.get_width() > 0, "achievement icon loaded: " + entry.id)
	await shot("achievements")
	var secret = screen.find_child("Achievement_oathbound", true, false)
	secret.pressed.emit()
	var detail = screen.find_child("AchievementDetail", true, false)
	var labels = detail.find_children("*", "Label", true, false)
	check(labels.any(func(l): return l.text == "Eco desconocido"), "locked secret conceals title")
	check(labels.all(func(l): return "Guerrero" not in l.text and "Guardiana" not in l.text and "/" not in l.text), "secret panel reveals no conditions")
	await click(screen.get_node("UnlocksTab"))
	check(screen.find_children("Achievement_*", "Button", true, false).is_empty(), "tabs replace content")
	check(screen.find_children("*", "Label", true, false).any(func(l): return l.text == "Reloj sin arena"), "legacy relic unlock retained")
	await shot("unlocks")
	await click(screen.get_node("HistoryTab"))
	check(screen.find_children("*", "Label", true, false).any(func(l): return "Tu historia" in l.text), "empty history explained")
	check(app.game.profile == before, "view and tab changes do not mutate profile")
	await click(screen.get_node("CollectionHome"))
	check(app.screen == "home", "Home button navigates to title screen")
	app.game.profile.victories = 1
	app.game.profile.attempts = 3
	app.game.profile.history = [{"won": true, "party": ["warrior", "guardian"], "rooms": 40}]
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
	await shot("history")
	app.queue_free();await process_frame;await create_timer(0.15).timeout
	print("COLLECTION UI: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
