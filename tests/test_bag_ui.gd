extends SceneTree
var app: Control
var failures = 0
var checks = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr(message)
func tap(node: Control) -> void:
	for down in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		event.position = node.get_global_rect().get_center()
		root.push_input(event)
	await process_frame
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://unused-bag.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "guardian"], 42)
	app.game.enter_node(0)
	app.screen = "items"
	app.render()
	for id in app.game.content.items:
		var button = app.layer.get_node("Item_" + id)
		check(not button.disabled, "empty item remains inspectable")
		check(is_equal_approx(button.get_rect().get_center().distance_to(Vector2(640,358)),190), "circular position")
		await tap(button)
		check(app.selected_item == id and app.layer.has_node("ItemPopover"), "item opens anchored popup")
		check(app.layer.get_node("Quantity_" + id).value == 0, "zero quantity")
		check(app.layer.get_node("ItemPopover/ConsumeUnavailable").disabled, "empty cannot consume")
		var popup = app.layer.get_node("ItemPopover")
		check(popup.position.x + popup.size.x < 400 or popup.position.x > 880, "popup outside circle")
	app.game.run.inventory.agility_brew = 2
	app.screen = "items"
	app.render()
	await tap(app.layer.get_node("Item_agility_brew"))
	check(app.layer.get_node("Quantity_agility_brew").value == 2, "quantity comes from inventory")
	check(app.layer.has_node("ItemPopover/Consume_0/TargetPortrait0") and app.layer.has_node("ItemPopover/Consume_0/TargetPortrait1"), "team item shows both heroes in one action")
	if DisplayServer.get_name() != "headless":
		await create_timer(0.2).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("objects/circular-bag.png"))
	await tap(app.layer.get_node("ItemPopover/Consume_0"))
	check(app.screen == "combat" and app.game.run.inventory.agility_brew == 1, "consume once and return")
	app.game.run.inventory.healing_potion = 1
	for hero in app.game.run.heroes: hero.hp -= 20
	app.screen = "items"
	app.render()
	await tap(app.layer.get_node("Item_healing_potion"))
	var popup = app.layer.get_node("ItemPopover")
	for i in range(2):
		var portrait = popup.get_node("Consume_%d/TargetPortrait0" % i)
		check(portrait.texture.atlas.resource_path.ends_with(app.game.run.heroes[i].id + ".png"), "portrait matches hero target")
		check(portrait.mouse_filter == Control.MOUSE_FILTER_IGNORE, "portrait passes clicks to consume action")
	check(popup.get_node("Consume_0").position.y == popup.get_node("Consume_1").position.y, "hero choices side by side")
	await shot("hero-targets")
	var previous_hp = app.game.run.heroes[0].hp
	var healed_hp = app.game.run.heroes[1].hp
	await tap(popup.get_node("Consume_1/TargetPortrait0"))
	check(app.game.run.heroes[0].hp == previous_hp and app.game.run.heroes[1].hp == healed_hp + 12 and app.game.run.inventory.healing_potion == 0, "portrait consumes exactly once on chosen hero")
	var battle = app.game.run.combat
	battle.enemies = [battle.enemies[0].duplicate(true), battle.enemies[0].duplicate(true), battle.enemies[0].duplicate(true)]
	app.game.run.inventory.concentrated_poison = 1
	app.screen = "items"
	app.render()
	await tap(app.layer.get_node("Item_concentrated_poison"))
	popup = app.layer.get_node("ItemPopover")
	for i in range(3):
		check(popup.has_node("Consume_%d/TargetPortrait0" % i), "offensive item shows every living enemy")
		check(popup.get_node("Consume_%d" % i).get_rect().end.x <= popup.size.x - 20, "three enemy portraits fit popup")
	await shot("enemy-targets")
	await tap(popup.get_node("Consume_2/TargetPortrait0"))
	check(battle.enemies[2].poison == 6 and battle.enemies[0].poison == 0 and app.game.run.inventory.concentrated_poison == 0, "enemy portrait uses original target index")
	app.game.run.inventory.concentrated_poison = 1
	battle.enemies[1].hp = 0
	app.screen = "items"
	app.render()
	await tap(app.layer.get_node("Item_concentrated_poison"))
	check(not app.layer.has_node("ItemPopover/Consume_1") and app.layer.has_node("ItemPopover/Consume_2"), "dead enemy excluded without renumbering valid targets")
	app.game.run.heroes[0].hp = 0
	app.game.run.inventory.phoenix_feather = 1
	app.screen = "items"
	app.render()
	await tap(app.layer.get_node("Item_phoenix_feather"))
	check(app.layer.has_node("ItemPopover/Consume_0/TargetPortrait0") and not app.layer.has_node("ItemPopover/Consume_1"), "revive shows only the fallen hero")
	await shot("revive-target")
	await tap(app.layer.get_node("ItemPopover/Consume_0/TargetPortrait0"))
	check(app.game.run.heroes[0].hp > 0 and app.game.run.inventory.phoenix_feather == 0, "fallen portrait revives chosen hero once")
	app.game._make_reward()
	app.screen = "items"
	app.render()
	await tap(app.layer.get_node("Item_agility_brew"))
	check(app.layer.get_node("ItemPopover/ConsumeUnavailable").disabled, "outside combat cannot consume")
	await tap(app.layer.get_node("BackFromBag"))
	check(app.screen == "reward", "return to pending reward")
	print("BAG UI: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)

func shot(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("objects/" + id + ".png"))
