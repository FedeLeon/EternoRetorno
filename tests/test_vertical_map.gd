extends SceneTree
const Game = preload("res://src/game.gd")
const Layout = preload("res://src/ui/components/vertical_map_layout.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ",message)
func shot(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("vertical_map/"+id+".png"))
func verify() -> void:
	var game = Game.new("user://unused-vertical-map",false)
	for floor_number in [1,2,3]:
		for seed_value in range(10):
			game.new_run(["warrior","guardian"],seed_value,{},floor_number)
			var before = game.run.duplicate(true)
			var state = game.rng.state
			var layout = Layout.new()
			layout.build(game.run.nodes)
			check(layout.height > 1500, "vertical content spreads stages over several screens")
			for node in game.run.nodes:
				var point: Vector2 = layout.positions[node.id]
				check(point.x > 80 and point.x < Layout.WIDTH-80, "rooms clear lateral viewport edges")
				for next in node.next:
					check(layout.positions[next].y < point.y, "every path climbs toward the boss")
				for other in game.run.nodes:
					if other.id != node.id: check(point.distance_to(layout.positions[other.id]) >= 150, "rooms remain separated")
			var boss = game.run.nodes.filter(func(n):return n.kind == "boss")[0]
			check(game.run.nodes.all(func(n):return layout.positions[n.id].y >= layout.positions[boss.id].y), "boss at highest point")
			var legacy = game.run.nodes.duplicate(true)
			for node in legacy:
				node.erase("stage"); node.erase("layout_version"); node.erase("position")
			var old_layout = Layout.new()
			old_layout.build(legacy)
			check(old_layout.positions == layout.positions, "old saves use graph without coordinate migration")
			check(game.run == before and game.rng.state == state, "layout never changes graph or gameplay RNG")
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = game
	root.add_child(app)
	app.continue_run()
	await process_frame
	await process_frame
	var view = app.layer.get_node("MapScreen")
	check(view.scroll.scroll_vertical > 1000, "initial view starts at bottom")
	check(view.scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED and view.scroll.clip_contents, "vertical viewport clips map content")
	check(view.scroll.get_global_rect().encloses(view.route.get_node("Room0").get_global_rect()), "entry is visible on opening")
	await shot("bottom")
	var rail = view.get_node("SideRail").global_position
	var before = game.run.duplicate(true)
	var old_scroll = view.scroll.scroll_vertical
	for pressed in [true,false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_WHEEL_UP
		event.pressed = pressed
		event.position = view.scroll.get_global_rect().get_center()
		root.push_input(event)
	await process_frame
	check(view.scroll.scroll_vertical < old_scroll, "mouse wheel scrolls upward")
	view.scroll.scroll_vertical = 800
	await process_frame
	await shot("middle")
	view.scroll.scroll_vertical = 0
	await process_frame
	check(view.get_node("SideRail").global_position == rail, "sidebar stays fixed while scrolling")
	var boss = view.nodes.filter(func(n):return n.kind == "boss")[0]
	check(view.scroll.get_global_rect().encloses(view.route.get_node("Room%d"%boss.id).get_global_rect()), "boss visible at top scroll position")
	check(game.run == before, "scrolling never moves party or changes adventure")
	await shot("top")
	app.game.run.current = 10
	app.game.run.phase = "map"
	app.screen = "map"
	app.render()
	await process_frame
	await process_frame
	view = app.layer.get_node("MapScreen")
	check(view.route.get_node("Room10").has_node("PartyHero0") and view.route.get_node("Room10").has_node("PartyHero1"), "party portraits mark current room")
	check(view.scroll.get_global_rect().encloses(view.route.get_node("Room10").get_global_rect()), "reopening focuses current party location")
	await shot("current")
	app.queue_free()
	await process_frame
	print("VERTICAL MAP: %d checks / %d failures"%[checks,failures])
	quit(1 if failures else 0)
