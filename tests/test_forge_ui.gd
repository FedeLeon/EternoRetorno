extends SceneTree
const Game = preload("res://src/game.gd")
var app: Control
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(value: bool, caption: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: ", caption)
func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("forge/" + file))
func click(point: Vector2) -> void:
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
	app.game = Game.new("user://unused-forge-ui.save", false)
	root.add_child(app)
	app.open_base_camp()
	await process_frame
	app.layer.get_node("Plot2").pressed.emit()
	check(is_instance_valid(app.overlay), "solar 3 opens construction")
	app.close_modal()
	check(app.game.build_forge(), "construct")
	check(app.game.build_market(), "market and forge coexist")
	app.open_base_camp()
	await process_frame
	check(app.layer.has_node("ForgeBuilding"), "building appears")
	check(app.layer.has_node("MarketBuilding"), "market still visible")
	await capture("camp.png")
	await click(app.layer.get_node("Plot0").get_meta("caption_rect").get_center())
	check(app.screen == "market", "forge does not cover market entrance")
	app.open_base_camp()
	await process_frame
	await click(app.layer.get_node("Plot2").get_meta("caption_rect").get_center())
	await process_frame
	check(app.screen == "forge", "enter forge")
	for id in app.game.content.heroes:
		app.layer.get_node("ForgeHero_" + id).pressed.emit()
		await process_frame
		check(app.forge_hero == id, "select " + id)
		var before = app.game.profile.souls
		app.layer.get_node("Upgrade_weapon").pressed.emit()
		await process_frame
		check(app.game.profile.souls == before - 150, "weapon purchase " + id)
		check(app.layer.get_node("SoulNumber").value == app.game.profile.souls, "visible balance refreshed")
		check(app.game.Forge.levels(app.game.profile, id).weapon == 1, "weapon level " + id)
		app.layer.get_node("Upgrade_armor").pressed.emit()
		await process_frame
		check(app.game.Forge.levels(app.game.profile, id).armor == 1, "armor level " + id)
	app.forge_hero = "warrior"
	app.render()
	await create_timer(0.2).timeout
	await capture("interior.png")
	app.game.profile.souls = 0
	app.render()
	await process_frame
	check(app.layer.get_node("Upgrade_weapon").disabled, "insufficient souls disabled")
	app.game.profile.souls = 5000
	app.game.profile.forge_upgrades.warrior = {"weapon": 3, "armor": 3}
	app.render()
	await process_frame
	check(app.layer.get_node("Upgrade_weapon").disabled and app.layer.get_node("Upgrade_armor").disabled, "both maximum tiers disabled")
	var back_button = app.layer.find_children("*", "Button", true, false).filter(func(button): return button.text == "Campamento")[0]
	await click(back_button.get_global_rect().get_center())
	check(app.screen == "base_camp", "top camp button returns to camp")
	for pair in [["warrior", "guardian"], ["rogue", "mage"], ["cleric", "ranger"]]:
		for id in pair:
			app.game.profile.forge_upgrades[id] = {"weapon": 3, "armor": 3}
		app.game.new_run(pair, 42)
		app.continue_run()
		await process_frame
		if pair[0] == "warrior": await capture("map.png")
		app.game.enter_node(0)
		app.continue_run()
		await create_timer(0.2).timeout
		for i in range(2):
			var texture = app.hero_art[i].sprite.sprite_frames.get_frame_texture("idle", 0)
			check(texture.atlas.resource_path.ends_with("%s_w3_a3.png" % pair[i]), "battle displays upgraded gear " + pair[i])

		var hud = app.layer.get_node("CombatHUD")
		check(hud.equipment.size() == 4, "both upgraded tracks of each hero in HUD")
		for i in range(4):
			var entry = hud.equipment[i]
			check(entry.level == 3 and entry.texture != null, "level-specific equipment asset")
			await click(hud.get_node("Relic%d" % (hud.relics.size() + i)).get_global_rect().get_center())
			check(is_instance_valid(hud.popover), "equipment opens anchored description")
			var labels = hud.popover.find_children("*", "Label", true, false)
			check(labels[0].text.contains(entry.owner) and labels[0].text.contains("Nivel 3"), "description identifies owner and level")
			check(labels[1].text.contains("+3" if i % 2 == 0 else "+6"), "description uses applied bonus")
		await capture("combat-" + pair[0] + ".png")
	print("FORGE UI: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
