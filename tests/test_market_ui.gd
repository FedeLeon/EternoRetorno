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
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-market-ui.save", false)
	root.add_child(app)
	app.open_base_camp()
	await process_frame
	app.layer.get_node("Plot0").pressed.emit()
	check(is_instance_valid(app.overlay), "build dialog")
	app.close_modal()
	check(app.game.build_market(), "construction")
	app.open_base_camp()
	app.layer.get_node("Plot0").pressed.emit()
	await process_frame
	check(app.screen == "market", "built plot opens shop")
	check(app.market_hero == "" and not app.layer.has_node("MarketCards"), "shop starts in portrait gallery")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("market/gallery.png"))
	for hero in app.game.content.heroes:
		app.layer.get_node("Category_" + hero).pressed.emit()
		await process_frame
		check(app.market_hero == hero, "category " + hero)
		check(not app.layer.has_node("Category_" + hero), "gallery hidden in shop detail")
		var purchases = app.layer.find_children("Buy_*", "Button", true, false)
		check(purchases.size() == 10, "ten purchasable cards")
		var scroll = app.layer.get_node("MarketCards")
		scroll.scroll_vertical = 650
		await process_frame
		var scroll_position = scroll.scroll_vertical
		check(scroll_position > 0, "list scrolled before buying")
		var buy = purchases[4]
		var id = String(buy.name).trim_prefix("Buy_")
		var balance = app.game.profile.souls
		buy.pressed.emit()
		await process_frame
		await process_frame
		check(app.layer.get_node("MarketCards").scroll_vertical == scroll_position, "purchase preserves scroll " + hero)
		check(id in app.game.profile.market_cards, "purchase " + hero)
		check(app.game.profile.souls == balance - app.game.content.cards[id].market_price, "balance updated")
		check(app.layer.find_child("Buy_" + id, true, false).disabled, "owned disabled")
		app.layer.get_node("BackToHeroes").pressed.emit()
		await process_frame
		check(app.market_hero == "" and not app.layer.has_node("MarketCards"), "back to hero cards")
	app.market_hero = "mage"
	app.render()
	await create_timer(0.2).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("market/interior.png"))
	app.back()
	check(app.screen == "market" and app.market_hero == "", "back from detail returns to heroes")
	app.back()
	check(app.screen == "base_camp", "back from gallery returns to camp")
	app.open_market()
	check(app.market_hero == "", "reenter market starts with hero cards")
	print("MARKET UI: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
