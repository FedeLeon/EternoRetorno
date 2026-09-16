extends SceneTree
const Game = preload("res://src/game.gd")
const BlockIndicator = preload("res://src/ui/components/block_indicator.gd")
const NumberView = preload("res://src/ui/components/number_view.gd")
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
func shot(name: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("hud/" + name + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-hud.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "cleric"], 12, {"team": "phoenix_idol"})
	app.game.enter_node(0)
	app.game.run.heroes[0].block = 12
	app.game.run.heroes[0].poison = 2
	app.game.run.combat.enemies[0].block = 7
	app.game.run.combat.enemies[0].poison = 4
	app.continue_run()
	await process_frame
	var hud = app.layer.get_node("CombatHUD")
	check(hud.relics.size() == 1, "One equipped relic in toolbar")
	check(hud.get_node("Relic0").global_position.y == 4, "Relics at top left")
	for key in ["Relic0", "Bag", "Deck"]:
		var target = hud.get_node(key)
		check(target.text == "" and target.get_theme_stylebox("normal") is StyleBoxEmpty, key + " image only")
	check(hud.get_node("EnergyNumber").value == app.game.run.combat.energy, "Energy matches rules")
	await click(hud.get_node("Deck").get_global_rect().get_center())
	check(app.screen == "deck", "Three-card icon opens deck")
	app.back()
	await process_frame
	hud = app.layer.get_node("CombatHUD")
	var indicators = app.layer.find_children("*", "", true, false).filter(func(n): return n is BlockIndicator)
	check(indicators.size() == 4 and indicators.all(func(n): return n.amount > 0), "Only active statuses shown")
	check(indicators.any(func(n): return n.amount == 12) and indicators.any(func(n): return n.amount == 7), "Hero and enemy block amounts")
	for indicator in indicators:
		check(indicator.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Block does not intercept targeting")
		check(indicator.get_child(1).value == indicator.amount, "Block digits match state")
	check(indicators.filter(func(n): return n.name == "Poison").size() == 2, "Poison icon on hero and enemy")
	check(indicators.filter(func(n): return n.name == "Poison").all(func(n): return n.icon_texture != null), "Poison has dedicated icon")
	await shot("combat")
	if DisplayServer.get_name() != "headless":
		var before = root.get_texture().get_image().get_region(Rect2i(16, 572, 140, 140))
		await create_timer(0.4).timeout
		await RenderingServer.frame_post_draw
		var after = root.get_texture().get_image().get_region(Rect2i(16, 572, 140, 140))
		check(before.get_data() != after.get_data(), "Rendered energy moves over time")
		before.save_png(preload("res://tests/artifacts.gd").path("hud/energy-frame-a.png"))
		after.save_png(preload("res://tests/artifacts.gd").path("hud/energy-frame-b.png"))
	await click(hud.get_node("Relic0").get_global_rect().get_center())
	check(is_instance_valid(hud.popover) and not is_instance_valid(app.overlay), "Anchored description without modal")
	check(hud.popover.find_children("*", "Label", true, false).any(func(n): return "Clériga" in n.text), "Phoenix state identifies each hero")
	check(hud.popover.find_children("*", "Button", true, false).is_empty(), "Description has no buttons")
	check(hud.popover.position.y == 70, "Description below relic")
	await shot("relic-popover")
	await click(Vector2(600, 250))
	check(not is_instance_valid(hud.popover), "Outside touch closes description")
	await click(hud.get_node("Relic0").get_global_rect().get_center())
	await click(hud.get_node("Relic0").get_global_rect().get_center())
	check(not is_instance_valid(hud.popover), "Second relic touch closes")
	await click(hud.get_node("Relic0").get_global_rect().get_center())
	app.back()
	check(not is_instance_valid(hud.popover) and app.screen == "combat", "Back dismisses description")
	check(hud.get_node("EnergyOrb").material is ShaderMaterial, "Energy flow shader attached")
	for actor in app.hero_art.values() + app.enemy_art.values():
		check(actor.scale == Vector2.ONE * 1.25, "Combat actors enlarged by 25 percent")
	await click(Vector2(925, 32))
	check(app.screen == "items", "Icon bag opens")
	app.back()
	await process_frame
	app.combat_busy = true
	await click(Vector2(925, 32))
	check(app.screen == "combat", "Bag blocked during action")
	app.combat_busy = false
	for unit in app.game.run.heroes + app.game.run.combat.enemies:
		unit.block = 0
		unit.poison = 0
	app.game.run.combat.energy = 0
	app.game.run.combat.turn = 12
	app.continue_run()
	await process_frame
	check(app.layer.find_children("*", "", true, false).filter(func(n): return n is BlockIndicator).is_empty(), "Indicators disappear when statuses expire")
	hud = app.layer.get_node("CombatHUD")
	check(hud.get_node("EnergyNumber").value == 0, "Zero energy visible")
	check(hud.get_node("TurnNumber").get_child_count() == 2, "Multi-digit turn")
	await shot("zero-energy")
	var display = NumberView.new()
	display.size = Vector2(200, 48)
	root.add_child(display)
	for value in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 99, 123, 2026]:
		display.value = value
		check(display.get_child_count() == str(value).length(), "Digit count " + str(value))
		for glyph in display.get_children():
			check(glyph.position.x >= 0 and glyph.position.x + glyph.size.x <= display.size.x + 0.1, "Glyph fits")
			check(glyph.texture.get_image().get_pixel(0, 0).a == 0, "Transparent digit")
	display.free()
	var hand = app.layer.get_node("CombatHand").get_child(0)
	check(hand.get_child(0).get_node("CostNumber") is NumberView, "Card cost uses shared digits")
	print("HUD CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
