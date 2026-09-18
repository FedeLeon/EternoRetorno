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
	ui.game._make_reward()
	ui.continue_run()
	await process_frame
	var offered = ui.game.run.reward.duplicate(true)
	var old_size = ui.game.run.deck.size()
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
	if DisplayServer.get_name() != "headless":
		await create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("reward/selection.png"))
	ui.layer.get_node("RewardCard0").pressed.emit()
	check(ui.game.run.deck.size() == old_size + 1 and ui.game.run.reward.is_empty(), "one reward granted")
	check(not ui.game.choose_reward(0), "cannot duplicate reward")
	print("REWARD UI FAILURES: ", failures)
	quit(1 if failures else 0)
