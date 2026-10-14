extends SceneTree
const Game = preload("res://src/game.gd")
const Art = preload("res://src/ui/components/card_art.gd")
var checks = 0
var failures = 0
var app: Control
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func shot(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("support_cards/" + name + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-support-ui.save", false)
	root.add_child(app)
	app.layer.hide()
	var additions = JSON.parse_string(FileAccess.get_file_as_string("res://data/support_cards.json"))
	for hero in app.game.content.heroes:
		var page = Control.new()
		root.add_child(page)
		var bg = ColorRect.new()
		bg.color = Color("10141f")
		bg.size = Vector2(1280,720)
		page.add_child(bg)
		var index = 0
		for id in additions:
			if additions[id].owner != hero: continue
			var texture = Art.texture_for(id)
			check(texture != null and texture.get_width() == 512, "bounded unique art " + id)
			for upgraded in [false,true]:
				for size in [Vector2(174,278),Vector2(218,278),Vector2(220,300),Vector2(224,244)]:
					var card = app.card_panel({"id":id,"upgraded":upgraded},0,0,size.x,size.y,func(): pass,false,true,page,true)
					await process_frame
					var description = card.get_node("CardDescription")
					var title = card.get_node("CardTitle")
					check(title.get_line_count() == 1 and title.size.x <= size.x * 0.62 + 1, "complete title fits " + id)
					check(description.position.y + (description.size.y + description.get_line_count() * description.get_line_height()) / 2 <= size.y - 29, "text above badge " + id)
					check(description.get_line_count() * description.get_line_height() <= description.size.y + 1, "description fits " + id)
					card.free()
			app.card_panel({"id":id,"upgraded":false},20+index*314,76,298,470,func(): pass,false,true,page,true)
			index += 1
		await shot(hero)
		page.free()
	app.layer.show()
	app.game.new_run(["warrior","rogue"], 12)
	app.game.enter_node(0)
	var b = app.game.run.combat
	b.enemies = [{"id":"skeleton", "hp":100, "max_hp":100, "block":15, "poison":0,"weak_pct":25,"fracture_pct":25,"intent":{"damage":12,"block":12,"target":0}}]
	app.game.run.heroes[0].strength_pct = 25
	b.hand = additions.keys().filter(func(id): return additions[id].owner == "warrior").map(func(id): return {"id":id,"upgraded":false})
	app.continue_run()
	await process_frame
	var intent = app.layer.get_node("EnemyIntent0")
	check(intent.get_node("Attack").amount == 9 and intent.get_node("Block").amount == 9, "intent displays effective values")
	var buff = app.hero_art[0].get_parent().get_node("HeroEffects/Effect_strength")
	check(buff.get_meta("battle_effect").value == 25 and buff.get_child(1).text == "25%", "hero buff icon")
	var enemy_effects = intent.get_node("EnemyEffects")
	check(enemy_effects.has_node("Effect_weakness") and enemy_effects.has_node("Effect_fracture"), "both enemy debuffs visible")
	await shot("combat")
	for pressed in [true, false]:
		var click = InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = pressed
		click.position = buff.get_global_rect().get_center()
		Input.parse_input_event(click)
		await process_frame
	await process_frame
	check(is_instance_valid(app.overlay), "buff explanation opens")
	await shot("effect-tip")
	app.close_modal()
	app.game.profile.buildings.market = true
	app.game.profile.souls = 10000
	app.open_market()
	app.market_hero = "warrior"
	app.render()
	await process_frame
	var scroll = app.layer.get_node("MarketCards")
	scroll.scroll_vertical = 9999
	await process_frame
	for id in additions:
		if additions[id].owner == "warrior":
			check(app.layer.find_child("Buy_" + id,true,false) != null, "new purchase button " + id)
	await shot("market-new-cards")
	app.layer.find_child("Buy_warrior_rally",true,false).pressed.emit()
	await process_frame
	check("warrior_rally" in app.game.profile.market_cards, "new card purchase through UI")
	print("SUPPORT UI: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
