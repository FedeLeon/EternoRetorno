extends SceneTree
const Game = preload("res://src/game.gd")
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
var failures = 0
var checks = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func click(point: Vector2) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame
func shot(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("camp_companions/" + file + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-companions.save", false)
	root.add_child(app)
	for id in ["market","forge","expeditions","church"]: app.game.profile.buildings[id] = true
	app.game.new_run(["warrior","guardian"], 32)
	app.game.enter_node(0)
	var profile = app.game.profile.duplicate(true)
	var random_state = app.game.rng.state
	app.open_base_camp()
	await process_frame
	var refuge = app.layer.get_node("RefugeBuilding").get_rect()
	check(not refuge.intersects(app.layer.get_node("MarketBuilding").get_rect()), "Refuge clears the market")
	check(absf(refuge.get_center().x - app.layer.get_node("DayCampfire").position.x) < 32 and refuge.end.y < app.layer.get_node("DayCampfire").position.y - 70, "Refuge sits above the central circle")
	var adventure = app.layer.get_node("CampExit")
	check(adventure.size == Vector2(164,164), "Large square adventure button")
	var play = adventure.get_node("AdventurePlay")
	check(play.texture.resource_path.ends_with("play.svg") and play.size.x >= 112, "Large actual play asset")
	check(play.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Play illustration does not intercept clicks")
	var electricity = adventure.get_node("Electricity")
	check(electricity.rectangular and electricity.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Square electricity does not intercept clicks")
	check(electricity.rim_point(0, 30).is_equal_approx(Vector2(156,82)), "Electric arcs follow square edge")
	var previous_elapsed = electricity.elapsed
	electricity._process(0.3)
	check(electricity.elapsed > previous_elapsed, "Electricity advances")
	var dog = app.layer.get_node("CampDog")
	var cat = app.layer.get_node("CampCat")
	check(dog.behavior != cat.behavior, "Animals start with different actions")
	for pet in [dog,cat]:
		pet.set_process(false)
		check(pet.sprite.hframes == 4 and pet.sprite.vframes == 2, "Eight authored poses: " + pet.species)
		var image = pet.sprite.texture.get_image()
		var hashes: Array = []
		for i in range(8):
			var tile = image.get_region(Rect2i((i % 4)*192,(i / 4)*192,192,192))
			check(Pack.bounds(tile,0.5).end.y == 174, "Feet have a common baseline: " + pet.species + str(i))
			var digest = hash(tile.get_data())
			check(digest not in hashes, "Distinct authored pose: " + pet.species + str(i))
			hashes.append(digest)
		var position_before = pet.position
		pet.behavior = "walk"
		pet.direction = 1
		pet.remaining = 5
		pet.animation_clock = 0
		pet.update_pose()
		pet._process(0.2)
		check(pet.position.x > position_before.x and pet.sprite.frame == 1, "Walking advances legs and ground position: " + pet.species)
		pet.behavior = "eat"
		pet.animation_clock = 0
		pet.remaining = 5
		position_before = pet.position
		pet._process(0.3)
		check(pet.position == position_before and pet.sprite.frame >= 4, "Eating moves pose but keeps feet in place: " + pet.species)
		var behaviors: Dictionary = {}
		for i in range(400):
			pet._process(0.1)
			behaviors[pet.behavior] = true
		check(behaviors.size() == 3, "Walking, eating and pauses alternate: " + pet.species)
		check(pet.position.x >= pet.walk_bounds.x and pet.position.x <= pet.walk_bounds.y and pet.position.y == pet.ground_y, "Animal stays on its ground path: " + pet.species)
	check(app.game.rng.state == random_state and app.game.profile == profile, "Decorations preserve gameplay RNG and saved progress")
	await shot("camp")
	await click(play.get_global_rect().get_center())
	check(is_instance_valid(app.overlay) and app.overlay.has_node("NewAdventure") and not app.overlay.get_node("ContinueAdventure").disabled, "Clicking play preserves new/continue adventure menu")
	app.close_modal()
	await click(app.layer.get_node("CampTent").get_meta("caption_rect").get_center())
	check(app.screen == "refuge", "Relocated refuge caption opens the hero gallery")
	app.queue_free()
	await process_frame
	print("CAMP COMPANIONS: ", checks, " checks / ", failures, " failures")
	quit(1 if failures else 0)
