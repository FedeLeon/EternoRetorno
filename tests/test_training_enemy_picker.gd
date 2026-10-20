extends SceneTree
const Config = preload("res://src/ui/screens/training_config_dialog.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func press(host: Node, caption: String) -> void:
	var buttons = host.find_children("*", "Button", true, false).filter(func(b): return b.text == caption)
	check(buttons.size() == 1, "unique action: " + caption)
	if buttons.size() == 1: buttons[0].pressed.emit()
	await process_frame
func shot(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("training_picker/" + id + ".png"))
func verify() -> void:
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://unused-training-picker",false)
	app.game.profile.bestiary = {"rat":{},"skeleton":{}}
	root.add_child(app)
	app.screen = "training_setup"
	app.render()
	await process_frame
	var portraits = app.layer.find_children("TrainingHero_*", "Button", true, false)
	check(portraits.size() == 4, "four shared building portraits")
	for card in portraits: check(card.size == Vector2(244,254), "same large portrait geometry as buildings")
	portraits[0].pressed.emit()
	portraits[1].pressed.emit()
	var start = app.layer.get_children().filter(func(n): return n is Button and n.text == "Entrenar")[0]
	check(not start.disabled, "shared portraits allow selecting a pair")
	portraits[2].pressed.emit()
	check(portraits[2].modulate == Color.WHITE, "third hero cannot join selected pair")
	portraits[0].pressed.emit()
	check(start.disabled, "deselecting a hero disables training")
	await shot("heroes")
	var profile = app.game.profile.duplicate(true)
	Config.open(app)
	await process_frame
	check(app.overlay.find_children("*", "OptionButton", true, false).size() == 1, "only intent mode remains a dropdown")
	for i in range(3): check(app.overlay.get_node("ChooseRival%d" % i) is Button, "rival slot is a button")
	app.overlay.find_children("*", "SpinBox", true, false)[0].value = 17
	app.overlay.get_node("ChooseRival1").pressed.emit()
	await process_frame
	check(app.overlay.name == "TrainingEnemyPicker", "button opens enemy gallery")
	check(app.overlay.find_children("Rival_*", "Button", true, false).size() == 2, "only discovered enemies available")
	for card in app.overlay.find_children("Rival_*", "Button", true, false):
		check(card.get_children().any(func(n): return n is TextureRect and n.texture != null), "enemy card has battle artwork")
	await shot("enemies")
	app.overlay.find_child("Rival_skeleton",true,false).pressed.emit()
	await process_frame
	check(app.overlay.get_node("ChooseRival1").text.contains(app.game.content.enemies.skeleton.name), "chosen enemy displayed in correct slot")
	check(app.overlay.find_children("*", "SpinBox", true, false)[0].value == 17, "other settings preserved through selection")
	app.overlay.get_node("ChooseRival0").pressed.emit()
	await process_frame
	await press(app.overlay,"Volver")
	check(app.overlay.has_node("ChooseRival1"), "cancel gallery returns to draft")
	await shot("configured")
	await press(app.overlay,"Aplicar")
	check(app.training_config.enemies == ["skeleton"] and app.training_config.damage == 17, "apply commits selected slots and settings")
	Config.open(app)
	app.overlay.get_node("ChooseRival0").pressed.emit()
	await process_frame
	app.overlay.get_node("ClearRival").pressed.emit()
	await process_frame
	await press(app.overlay,"Aplicar")
	check(app.training_config.enemies.is_empty(), "clear last enemy restores dummy configuration")
	check(app.game.profile == profile, "selection never changes persistent profile")
	app.queue_free()
	await process_frame
	print("TRAINING PICKER: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
