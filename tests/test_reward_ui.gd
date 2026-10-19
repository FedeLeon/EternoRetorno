extends SceneTree
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr(message)
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var ui = load("res://main.tscn").instantiate()
	ui.game = preload("res://src/game.gd").new("user://unused-reward-ui.save", false)
	root.add_child(ui)
	ui.game.new_run(["warrior", "guardian"], 42)
	ui.game.enter_node(0)
	ui.continue_run()
	ui.open_deck()
	check(ui.layer.get_node("DeckSummary").text.contains("Descarte:"), "combat deck lists piles")
	preload("res://tests/room_fixture.gd").break_objective(ui.game)
	for enemy in ui.game.run.combat.enemies: enemy.hp = 0
	check(ui.game._check_combat_end(), "real victory grants pending reward and salvage")
	ui.continue_run()
	await process_frame
	var offered = ui.game.run.reward.duplicate(true)
	var old_size = ui.game.run.deck.size()
	var salvage = ui.game.profile.forge_materials.scrap
	check(ui.layer.has_node("SalvageReward/SalvageAmount") and ui.game.run.reward_salvage.scrap == salvage, "material receipt visible after victory")
	check(ui.layer.has_node("RewardBackground"), "reward background")
	check(ui.layer.has_node("CombatHUD/Deck") and ui.layer.has_node("CombatHUD/Bag"), "reward navigation")
	check(not ui.layer.has_node("CombatHUD/EnergyOrb"), "no combat energy on reward")
	check(ui.layer.get_node("RewardCard0").size.y > 400, "tall reward cards")
	ui.open_deck()
	check(ui.return_screen == "reward", "deck returns to reward")
	ui.screen = ui.return_screen
	ui.render()
	ui.layer.get_node("CombatHUD/Bag").pressed.emit()
	check(ui.screen == "items", "bag opens")
	ui.continue_run()
	check(ui.screen == "reward" and ui.game.run.reward == offered, "navigation preserves pending reward")
	check(ui.game.profile.forge_materials.scrap == salvage and ui.layer.has_node("SalvageReward"), "reward navigation preserves salvage without regranting it")
	if DisplayServer.get_name() != "headless":
		await create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("reward/selection.png"))
	ui.layer.get_node("RewardCard0").pressed.emit()
	check(ui.game.run.deck.size() == old_size + 1 and ui.game.run.reward.is_empty(), "one reward granted")
	check(not ui.game.choose_reward(0), "cannot duplicate reward")
	ui.game.new_run(["warrior", "guardian"], 42, {"team":"vital_amulet"})
	for node in ui.game.run.nodes:
		if node.kind != "elite": continue
		ui.game.run.current = node.id
		ui.game._start_combat(node.encounter)
		break
	for enemy in ui.game.run.combat.enemies: enemy.hp = 0
	ui.game._check_combat_end()
	var dropped = ui.game.run.reward_relic
	ui.continue_run()
	await process_frame
	check(ui.layer.has_node("SalvageReward"), "elite salvage shown alongside relic and cards")
	check(not ui.layer.get_node("SalvageReward").get_global_rect().intersects(ui.layer.get_node("EliteRelicReward").get_global_rect()), "salvage receipt stays clear of elite relic panel")
	check(ui.layer.has_node("EliteRelicReward/RelicArtwork"), "elite relic displayed alongside cards")
	check(ui.layer.get_node("RewardCard0").position.x > ui.layer.get_node("EliteRelicReward").get_rect().end.x, "relic does not overlap cards")
	check(ui.layer.get_node("CombatHUD").relics.size() == 2, "equipped and dropped relic in toolbar")
	ui.layer.get_node("CombatHUD/Relic1").pressed.emit()
	check(ui.layer.get_node("CombatHUD").popover != null, "dropped relic tooltip")
	ui.layer.get_node("CombatHUD").close_relic()
	ui.open_deck()
	ui.screen = ui.return_screen
	ui.render()
	check(ui.game.run.reward_relic == dropped and ui.layer.has_node("EliteRelicReward"), "return from deck keeps relic receipt")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("reward/elite.png"))
	ui.layer.get_node("RewardCard0").pressed.emit()
	check(dropped in ui.game.run.relics and ui.game.run.reward_relic == "", "choosing card retains relic and clears receipt")
	print("REWARD UI FAILURES: ", failures)
	quit(1 if failures else 0)
