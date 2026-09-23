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
func shot(name: String) -> void:
	await create_timer(0.2).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("objects/" + name + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-equipment-ui.save", false)
	root.add_child(app)
	app.open_selection()
	await process_frame
	await click(app.CAMP_POSITIONS[0] - Vector2(0, 50))
	await click(app.CAMP_POSITIONS[3] - Vector2(0, 50))
	await click(Vector2(1060, 675))
	check(app.screen == "equipment", "selection opens loadout")
	await click(Vector2(1060, 675))
	check(app.screen == "equipment" and app.game.run.is_empty(), "cannot begin without a relic")
	await click(app.layer.get_node("Equip_vital_amulet").get_global_rect().get_center())
	check(not is_instance_valid(app.overlay) and app.layer.has_node("EquipmentDescription"), "tap selects and opens non-modal description")
	await shot("relic-dialog")
	check(app.equipped == {"team":"vital_amulet"}, "choose team relic by pointer")
	check(not app.layer.find_children("*", "Button", true, false).any(func(n): return "Sin reliquia" in n.text or "Guerrero ·" in n.text), "No hero assignment buttons")
	for id in app.game.content.equipment:
		await click(app.layer.get_node("Equip_" + id).get_global_rect().get_center())
		check(app.equipped == {"team": id}, "tap replaces shared relic " + id)
		var popup = app.layer.get_node("EquipmentDescription")
		check(popup.position.x + popup.size.x < 384 or popup.position.x > 896, "description outside complete circle")
		check(popup.position.y >= 130 and popup.position.y + popup.size.y < 647, "description fits between header and navigation")
		check(not is_instance_valid(app.overlay), "description is not modal")
	await click(Vector2(640, 378))
	check(app.layer.has_node("EquipmentDescription"), "outside click keeps description")
	await click(app.layer.get_node("Equip_arcane_orb").get_global_rect().get_center())
	check(app.equipped == {"team":"arcane_orb"}, "replace single shared relic")
	await shot("loadout")
	var party = app.selected_party.duplicate()
	check(not app.game.profile.has("preparation"), "preparation not persisted")
	app.back()
	check(app.selected_party == party and app.equipped == {"team":"arcane_orb"}, "back preserves current preparation")
	app.open_base_camp()
	app.game.profile.preparation = {"party": party, "relics": {"team":"arcane_orb"}}
	app.open_selection()
	check(app.equipped.is_empty() and app.selected_party.is_empty() and not app.game.profile.has("preparation"), "new adventure clears legacy selection")
	for id in party: app.toggle_hero(id)
	app.equip_relic("arcane_orb")
	app.open_equipment()
	await process_frame
	await click(Vector2(1060, 675))
	app.overlay.get_node("StartDungeon1").pressed.emit()
	await process_frame
	check(app.screen == "map" and app.game.run.team_relic == "arcane_orb" and app.game.run.heroes.all(func(h): return h.equipped_relic == "arcane_orb"), "loadout applied to adventure")
	check(app.game.run.inventory.is_empty(), "new adventure has no consumables")
	app.game.run.inventory["agility_brew"] = 1 # Explicit UI fixture for bag use.
	app.game.enter_node(0)
	app.continue_run()
	await process_frame
	await click(Vector2(925, 32))
	check(app.screen == "items", "bag opens from combat")
	await shot("bag")
	await click(app.layer.get_node("Item_agility_brew").get_global_rect().get_center())
	check(app.selected_item == "agility_brew", "choose brew")
	await click(app.layer.get_node("ItemPopover/Consume_0").get_global_rect().get_center())
	check(app.screen == "combat" and app.game.run.combat.hand.size() == 8 and app.game.run.inventory.agility_brew == 0, "item resolves and returns to combat")
	await shot("expanded-hand")
	check(app.layer.get_children().any(func(n): return n is ScrollContainer), "eight cards have scrollable hand")
	print("EQUIPMENT UI CHECKS: %d | FAILURES: %d" % [checks, failures])
	quit(1 if failures else 0)
