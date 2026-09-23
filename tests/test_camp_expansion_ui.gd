extends SceneTree
const Game = preload("res://src/game.gd")
var app: Control
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", caption)
func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("camp_expansion/" + file + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-expansion-ui.save", false)
	root.add_child(app)
	app.open_base_camp()
	app.layer.get_node("Plot1").pressed.emit()
	check(is_instance_valid(app.overlay), "expeditions construction dialog")
	app.close_modal()
	app.game.camp_action("build", {"id":"expeditions"})
	app.game.camp_action("build", {"id":"church"})
	app.game.build_market()
	app.game.build_forge()
	app.open_base_camp()
	await process_frame
	check(app.layer.has_node("ChurchBuilding") and app.layer.has_node("ExpeditionsBuilding"), "both buildings")
	for pair in [["Plot1", "CampExit"], ["Plot3", "Plot1"]]:
		var building = app.layer.get_node(pair[0])
		var caption: Rect2 = app.layer.get_node(pair[1]).get_meta("caption_rect")
		check(not building._has_point(caption.get_center() - building.position), "neighbouring caption receives input")
	await capture("camp")
	app.layer.get_node("Plot1").pressed.emit()
	await process_frame
	check(app.screen == "expeditions", "open expeditions")
	var offers = app.layer.find_children("AcceptContract", "Button", true, false)
	check(offers.size() == 3, "three contracts")
	offers[0].pressed.emit()
	await process_frame
	check(app.game.profile.expeditions.selected != "", "contract selected")
	offers = app.layer.find_children("AcceptContract", "Button", true, false)
	check(not offers[0].disabled and offers[1].disabled and offers[2].disabled, "only selected contract allows cancellation")
	offers[0].pressed.emit()
	await process_frame
	check(app.game.profile.expeditions.selected == "", "contract cancelled")
	offers = app.layer.find_children("AcceptContract", "Button", true, false)
	for button in offers: check(not button.disabled, "cancellation unlocks all offers")
	offers[1].pressed.emit()
	await process_frame
	offers = app.layer.find_children("AcceptContract", "Button", true, false)
	check(offers[0].disabled and not offers[1].disabled and offers[2].disabled, "another contract can be selected after cancellation")
	await capture("contracts")
	app.back()
	app.layer.get_node("Plot3").pressed.emit()
	await process_frame
	check(app.screen == "church" and app.layer.find_children("ChurchHero_*", "Button", true, false).size() == 6, "six church portraits")
	await capture("church")
	for hero in app.game.content.heroes:
		app.layer.get_node("ChurchHero_" + hero).pressed.emit()
		await process_frame
		var choices = app.layer.find_children("LearnSpecialization", "Button", true, false)
		check(choices.size() == 2 and choices[0].disabled and choices[1].disabled, "locked specs " + hero)
		preload("res://src/rules/specializations.gd").victory(app.game.profile, [hero])
		app.game.profile.souls = 10000
		app.render()
		choices = app.layer.find_children("LearnSpecialization", "Button", true, false)
		choices[0].pressed.emit()
		await process_frame
		check(app.game.profile.specializations.active.has(hero), "learn activates " + hero)
		if hero == "warrior": await capture("specializations")
		app.back()
		check(app.screen == "church" and app.church_hero == "", "back to gallery")
	app.back()
	check(app.screen == "base_camp", "back to camp")
	app.game.new_run(["warrior","cleric"], 3)
	app.layer.get_node("Plot1").pressed.emit()
	for button in app.layer.find_children("AcceptContract", "Button", true, false): check(button.disabled, "contracts locked during run")
	print("CAMP EXPANSION UI: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
