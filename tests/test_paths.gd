extends SceneTree
const Game = preload("res://src/game.gd")
const Navigation = preload("res://src/ui/adventure_navigation.gd")
const Paths = preload("res://src/ui/screens/paths_screen.gd")
const AudioRouting = preload("res://src/audio/screen_audio.gd")
var checks = 0
var failures = 0
var app: Control
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", text)
func capture(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("paths/" + id + ".png"))
func click(button: Control) -> void:
	var point = button.get_global_rect().get_center()
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		root.push_input(event)
	await process_frame

func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-paths", false)
	root.add_child(app)
	app.game.profile.settings = {"auto_cinematics":false}
	for floor_number in [1, 2, 3]:
		for count in [1, 2, 3]:
			var candidate = -1
			for seed in range(50):
				app.game.new_run(["warrior", "guardian"], seed, {}, floor_number)
				for node in app.game.run.nodes:
					if node.next.size() == count:
						candidate = node.id
						break
				if candidate >= 0: break
			check(candidate >= 0, "real seeded branch exists")
			app.game.run.current = candidate
			app.game.run.visited = [candidate]
			var before = app.game.run.duplicate(true)
			app.continue_run()
			await process_frame
			check(app.screen == "paths" and app.game.run.phase == "map", "presentation keeps saved map phase")
			var view = app.layer.get_node("PathsScreen")
			check(view.get_node("PathsBackground").texture.resource_path == Paths.background_path(floor_number, count), "matching first-person scene")
			var buttons = view.get_children().filter(func(n): return n is Button and n.has_meta("room_id"))
			check(buttons.size() == count, "no invented or hidden exits")
			for id in app.game.available_nodes():
				var button = view.get_node("Path%d" % id)
				check(button.get_meta("kind") == app.game.run.nodes[id].kind, "destination icon describes actual room")
				check(button.get_global_rect().end.x < 1196, "path leaves rail clear")
				for next in app.game.run.nodes[id].next:
					check(button.has_node("Next%d" % next), "next alternatives match real edges")
			check(app.game.run == before, "drawing and preview do not mutate saved state")
			check(AudioRouting.context("paths", app.game.run) == AudioRouting.context("map", app.game.run), "zone ambience preserved")
			await capture("floor_%d_%d" % [floor_number, count])
			view.get_node("SideRail/Map").pressed.emit()
			await process_frame
			check(app.screen == "map" and app.game.run == before, "map inspection is read-only")
			app.layer.get_node("MapScreen/SideRail/Map").pressed.emit()
			await process_frame
			check(app.screen == "paths" and app.game.run == before, "return to the same paths")
			app.open_deck()
			await process_frame
			app.back()
			await process_frame
			check(app.screen == "paths", "deck returns to paths")
	# Real battle rewards precede route navigation; resume chooses the same scene.
	app.game.new_run(["warrior", "guardian"], 42)
	app.game.enter_node(0)
	preload("res://tests/room_fixture.gd").break_objective(app.game)
	for enemy in app.game.run.combat.enemies: enemy.hp = 0
	app.game._check_combat_end()
	app.continue_run()
	check(app.screen == "reward", "card reward remains first")
	app.act(func(): app.game.choose_reward(-1))
	await process_frame
	check(app.screen == "paths" and app.game.run.reward.is_empty(), "reward resolves before showing routes")
	var snapshot = app.game.run.duplicate(true)
	var available = app.game.available_nodes().duplicate()
	app.game.run = snapshot.duplicate(true)
	app.continue_run()
	check(app.screen == "paths" and app.game.available_nodes() == available, "resume reconstructs exact choices")
	var id: int = available[0]
	app.game.run.nodes[id].risk = {"name":"Cables expuestos", "warning":"Riesgo de prueba"}
	app.layer.get_node("PathsScreen/Path%d" % id).pressed.emit()
	check(is_instance_valid(app.overlay) and app.game.run.current == 0, "risk still requires its real confirmation")
	app.close_modal()
	app.game.run.nodes[id].erase("risk")
	await click(app.layer.get_node("PathsScreen/Path%d" % id))
	check(app.game.run.current == id and id in app.game.run.visited, "path button enters its exact destination")
	check(not app.game.enter_node(27), "unreachable boss remains rejected")
	app.queue_free()
	await process_frame
	print("PATHS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
