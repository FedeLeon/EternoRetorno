extends SceneTree
const Game = preload("res://src/game.gd")
const Roster = preload("res://src/rules/hero_roster.gd")
var checks = 0
var failures = 0
var app: Control
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",caption)
func click(button: Control) -> void:
	for pressed in [true,false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = button.get_global_rect().get_center()
		root.push_input(event)
	await process_frame
func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("building_interiors/"+file+".png"))
func gallery(screen: String) -> Control:
	return app.layer.get_node("RefugeScreen").body if screen == "refuge" else app.layer
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-building-gallery.save",false)
	root.add_child(app)
	var ids = Roster.ids(app.game.content.heroes)
	var prefixes = {"market":"Category_", "forge":"ForgeHero_", "church":"ChurchHero_", "refuge":"RefugeHero_"}
	for screen in prefixes:
		app.screen = screen
		app.render()
		await process_frame
		var profile = app.game.profile.duplicate(true)
		var cards: Array[Rect2] = []
		for id in ids:
			var card = gallery(screen).get_node(prefixes[screen]+id)
			var bounds: Rect2 = card.get_global_rect()
			check(Rect2(728,158,528,540).encloses(bounds),screen+": card stays in right block")
			for other in cards: check(not bounds.intersects(other),screen+": cards do not overlap")
			cards.append(bounds)
			var portrait = card.get_node("ComicPortrait")
			check(bounds.encloses(portrait.get_global_rect()),screen+": artwork stays inside card")
		check(is_equal_approx(cards[0].position.y,cards[1].position.y) and is_equal_approx(cards[2].position.y,cards[3].position.y),screen+": two cards per row")
		check(cards[2].end.y >= 680,screen+": gallery uses lower space")
		await capture(screen)
		for id in ids:
			await click(gallery(screen).get_node(prefixes[screen]+id))
			var selected = app.layer.get_node("RefugeScreen").selected if screen == "refuge" else app.get(screen+"_hero")
			check(selected == id,screen+": click selects correct hero "+id)
			if id == ids[0]: await capture(screen+"-detail")
			app.back()
			await process_frame
		check(app.game.profile == profile,screen+": selecting heroes does not change progress")
	for screen in ["expeditions"]:
		app.screen = screen
		app.render()
		await process_frame
		await capture(screen)
	app.queue_free()
	await process_frame
	print("BUILDING GALLERIES: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
