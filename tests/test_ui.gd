extends SceneTree
const Game = preload("res://src/game.gd")
var failures = 0
var checks = 0
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-ui-test.save", false)
	root.add_child(app)
	for id in app.game.content.cards:
		var owner = app.game.content.cards[id].owner
		app.game.new_run([owner, "warrior" if owner != "warrior" else "cleric"], 12)
		app.game.enter_node(0)
		app.game.run.combat.hand = [{"id": id, "upgraded": true}]
		app.continue_run()
		await process_frame
		await process_frame
		for child in app.layer.get_children():
			if child is Button and child.position.y == 444:
				for label in child.get_children():
					if label is Label:
						checks += 1
						if label.position.y + label.size.y > child.size.y + 1 or label.position.x + label.size.x > child.size.x + 1:
							failures += 1
							printerr("OVERFLOW ", id, ": ", label.text, " ", label.position, " ", label.size)
	# Native mouse events use the same Godot button actions as emulated touch.
	app.open_selection()
	await process_frame
	click(Vector2(130, 300))
	await process_frame
	click(Vector2(950, 300))
	await process_frame
	checks += 1
	if app.selected_party != ["warrior", "cleric"]:
		failures += 1
		printerr("Selection by input failed: ", app.selected_party)
	print("UI CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
func click(position: Vector2) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = position
		root.push_input(event)
