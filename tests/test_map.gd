extends SceneTree
const Game = preload("res://src/game.gd")
var app: Control
var checks = 0
var failures = 0
func _initialize() -> void:
	call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func click(point: Vector2) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		root.push_input(event)
	await process_frame
func shot(file: String = "initial") -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("map/" + file + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-map-test.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "cleric"], 42, {"team": "vital_amulet"})
	app.game.run.relics.append("ember")
	app.continue_run()
	await process_frame
	await process_frame
	var view = app.layer.get_node("MapScreen")
	check(view.relics.size() == 2 and view.relics[0].name == "Amuleto Vital", "equipped and found relics shown")
	check(view.get_node("GroupDrawer/Hero0").size.y > 80 and view.get_node("GroupDrawer/Health0") != null, "larger actor with health")
	check(not view.has_node("Descend"), "stairs hidden before boss victory")
	for i in range(28):
		var room = view.get_node("Room%d" % i)
		check(room.disabled == (i != 0), "only reachable rooms enabled")
		check(room.get_theme_stylebox("normal") is StyleBoxTexture, "room uses papyrus asset")
		check(not room.tooltip_text.contains(preload("res://src/dungeon.gd").LABELS[view.nodes[i].kind]), "tooltip does not reveal room type")
	check(view.has_node("RoomGlow0"), "entry illuminated before first encounter")
	check(view.get_node("RoomGlow0").mouse_filter == Control.MOUSE_FILTER_IGNORE, "entry glow does not block clicks")
	check(not view.has_node("RoomGlow1"), "unreachable room has no glow")
	var before = app.game.run.duplicate(true)
	await shot()
	await click(view.get_node("Room27").get_global_rect().get_center())
	check(app.screen == "map" and app.game.run == before, "unreachable boss click has no effect")
	var drawer = view.get_node("GroupDrawer")
	check(not drawer.opened and drawer.position.x == 1280, "group starts collapsed")
	await click(view.get_node("SideRail/GroupTab").get_global_rect().get_center())
	await create_timer(0.35).timeout
	check(drawer.opened and drawer.position.x == 686, "group slides left")
	check(not drawer.has_node("Deck"), "deck moved out of drawer")
	var relic_button = drawer.find_child("Relic0", true, false)
	await click(relic_button.get_global_rect().get_center())
	check(drawer.has_node("RelicPopover"), "relic click opens detail")
	await shot("group-open")
	await click(relic_button.get_global_rect().get_center())
	check(not drawer.has_node("RelicPopover"), "same relic closes detail")
	await click(relic_button.get_global_rect().get_center())
	await click(drawer.find_child("Relic1", true, false).get_global_rect().get_center())
	check(drawer.selected_relic.name == "Relic1", "another relic changes detail")
	var covered = view.get_node("Room13")
	covered.disabled = false # Test input interception independently of route rules.
	var received: Array = []
	view.room_requested.connect(func(id): received.append(id))
	await click(covered.get_global_rect().get_center())
	check(received.is_empty() and app.game.run == before, "drawer blocks covered map")
	covered.disabled = true
	await click(view.get_node("SideRail/GroupTab").get_global_rect().get_center())
	await create_timer(0.35).timeout
	check(not drawer.opened and drawer.position.x == 1280, "tab closes group")
	await click(view.get_node("SideRail/GroupTab").get_global_rect().get_center())
	await create_timer(0.35).timeout
	await click(view.get_node("SideRail/Deck").get_global_rect().get_center())
	check(app.screen == "deck" and app.game.run == before, "deck asset opens without changing run")
	app.back()
	await process_frame
	await click(app.layer.get_node("MapScreen/Room0").get_global_rect().get_center())
	check(app.screen == "combat" and app.game.run.current == 0, "room art click enters available encounter")
	app.game.run.phase = "map"
	app.game.run.current = 0
	app.continue_run()
	await process_frame
	view = app.layer.get_node("MapScreen")
	check(not view.get_node("Room1").disabled and not view.get_node("Room2").disabled, "branch availability retained")
	check(view.has_node("RoomGlow0") and not view.has_node("RoomGlow1"), "current room illuminated instead of next branch")
	var marker = view.get_node("Room0/CurrentRoomMarker")
	var icon = view.get_node("Room0/RoomIcon")
	check(is_equal_approx(marker.get_global_rect().get_center().x, icon.get_global_rect().get_center().x), "current marker centered above icon")
	check(marker.get_global_rect().end.y < icon.get_global_rect().position.y, "marker above room")
	for child in view.get_children():
		if child is Label:
			check(not child.text.contains(" · "), "no room captions")
	await shot("current-room")
	app.game.run.boss_defeated = true
	app.continue_run()
	await process_frame
	check(app.layer.get_node("MapScreen").has_node("Descend"), "stairs appear after boss")
	# Legacy personal equipment is still shown, once per bearer.
	app.game.run.erase("team_relic")
	app.continue_run()
	await process_frame
	check(app.layer.get_node("MapScreen").relics.size() == 3, "legacy personal equipment and found relic retained")
	print("MAP CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
