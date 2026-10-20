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
	app.game.new_run(["warrior", "guardian"], 42, {"team": "vital_amulet"})
	app.game.run.relics.append("ember")
	app.continue_run()
	await process_frame
	await process_frame
	var view = app.layer.get_node("MapScreen")
	check(view.relics.size() == 2 and view.relics[0].name == app.game.content.equipment["vital_amulet"].name, "equipped and found relics shown")
	check(view.get_node("GroupDrawer/Hero0").size.y > 80 and view.get_node("GroupDrawer/Health0") != null, "larger actor with health")
	check(not view.has_node("Descend"), "stairs hidden before boss victory")
	for i in range(28):
		var room = view.route.get_node("Room%d" % i)
		check(room.disabled == (i != 0), "only reachable rooms enabled")
		check(room.get_theme_stylebox("normal") is StyleBoxTexture, "room uses papyrus asset")
		check(not room.tooltip_text.contains(preload("res://src/dungeon.gd").LABELS[view.nodes[i].kind]), "tooltip does not reveal room type")
	check(view.route.has_node("RoomGlow0"), "entry illuminated before first encounter")
	check(view.route.get_node("RoomGlow0").mouse_filter == Control.MOUSE_FILTER_IGNORE, "entry glow does not block clicks")
	check(not view.route.has_node("RoomGlow1"), "unreachable room has no glow")
	var before = app.game.run.duplicate(true)
	await shot()
	await click(view.route.get_node("Room27").get_global_rect().get_center())
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
	var drawer_area = Rect2(drawer.global_position + Vector2(0,48),Vector2(510,672))
	var covered: Button = view.route.get_children().filter(func(child): return child is Button and child.name.begins_with("Room") and drawer_area.has_point(child.get_global_rect().get_center()))[0]
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
	await click(app.layer.get_node("MapScreen/MapScroll/Route/Room0").get_global_rect().get_center())
	check(app.screen == "combat" and app.game.run.current == 0, "room art click enters available encounter")
	app.game.run.phase = "map"
	app.game.run.current = 0
	app.screen = "map"
	app.render()
	await process_frame
	view = app.layer.get_node("MapScreen")
	check(not view.route.get_node("Room1").disabled and not view.route.get_node("Room2").disabled, "branch availability retained")
	check(view.route.has_node("RoomGlow0"), "current room retains its glow")
	for node in view.nodes:
		check(view.route.has_node("RoomGlow%d" % node.id) == (node.id == view.current or node.id in view.available), "only current and available rooms glow")
	var next_glow = view.route.get_node("RoomGlow1")
	check(next_glow.mouse_filter == Control.MOUSE_FILTER_IGNORE, "available glow ignores input")
	check(next_glow.get_index() < view.route.get_node("Room1").get_index(), "available glow behind papyrus")
	check(next_glow.get_theme_stylebox("panel").shadow_color != view.route.get_node("RoomGlow0").get_theme_stylebox("panel").shadow_color, "available and current have distinct colors")
	var alpha = next_glow.modulate.a
	await create_timer(0.45).timeout
	check(not is_equal_approx(alpha, next_glow.modulate.a) and next_glow.modulate.a > 0, "available halo pulses without disappearing")
	var marker = view.route.get_node("Room0/CurrentRoomMarker")
	var icon = view.route.get_node("Room0/RoomIcon")
	check(is_equal_approx(marker.get_global_rect().get_center().x, icon.get_global_rect().get_center().x), "current marker centered above icon")
	check(marker.get_global_rect().end.y < icon.get_global_rect().position.y, "marker above room")
	for child in view.get_children():
		if child is Label:
			check(not child.text.begins_with("Sala "), "no room captions")
	await shot("current-room")
	app.game.run.boss_defeated = true
	app.screen = "map"
	app.render()
	await process_frame
	check(app.layer.get_node("MapScreen").has_node("Descend"), "stairs appear after boss")
	# Legacy personal equipment is still shown, once per bearer.
	app.game.run.erase("team_relic")
	app.screen = "map"
	app.render()
	await process_frame
	check(app.layer.get_node("MapScreen").relics.size() == 3, "legacy personal equipment and found relic retained")
	print("MAP CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
