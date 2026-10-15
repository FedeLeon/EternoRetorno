extends SceneTree
const Game = preload("res://src/game.gd")
var failures = 0
var checks = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func _initialize() -> void: call_deferred("run_tests")
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://pixel-ui.save", false)
	root.add_child(app)
	app.game.new_run(["warrior", "guardian"], 91)
	app.game.enter_node(0)
	for enemy in app.game.run.combat.enemies:
		enemy.hp = 999
		enemy.max_hp = 999
		enemy.intent.damage = 0
	app.continue_run()
	await process_frame
	var action = app.layer.find_child("ReserveCard", true, false)
	check(action != null and action.disabled, "Reserve disabled until selecting a card")
	app.select_card(0)
	await process_frame
	action = app.layer.find_child("ReserveCard", true, false)
	check(not action.disabled, "Selected card can be reserved")
	var chosen = app.game.run.combat.hand[0].duplicate(true)
	var energy = app.game.run.combat.energy
	await click(action.get_global_rect().get_center())
	check(app.combat_busy and app.game.run.combat.reserved == [chosen], "Reserve resolves before visual flip")
	check(app.game.run.combat.energy == energy, "UI reserve keeps energy")
	while app.combat_busy: await process_frame
	await process_frame
	var reserved = app.layer.find_child("ReservedCard", true, false)
	check(reserved != null and reserved.get_parent() == app.layer.get_node("CombatHand").get_child(0), "Face-down card stays inside hand")
	check(reserved.get_parent().get_child_count() == 6 and reserved.get_parent().get_child(0) == reserved, "Reserve keeps six visible cards and original position")
	check(app.layer.find_child("ReserveCard", true, false).text == "Recuperar carta", "Control offers recovery instead of another reserve")
	await click(reserved.get_global_transform() * Vector2(50, 60))
	check(app.combat_busy and app.game.run.combat.reserved.is_empty(), "Undo commits before revealing the face")
	while app.combat_busy: await process_frame
	await process_frame
	check(app.game.run.combat.hand[0] == chosen and app.game.run.combat.hand.size() == 6, "Undo returns the same card to the playable hand")
	check(app.layer.find_child("ReserveCard", true, false).text == "Guardar carta", "Can reserve again after recovery")
	app.select_card(2); await process_frame
	var replacement = app.game.run.combat.hand[2].duplicate(true)
	await click(app.layer.find_child("ReserveCard", true, false).get_global_rect().get_center())
	while app.combat_busy: await process_frame
	await process_frame
	reserved = app.layer.find_child("ReservedCard", true, false)
	check(reserved.get_parent().get_child(2) == reserved and app.game.run.combat.reserved == [replacement], "Another chosen card flips in its original position")
	check(app.game.run.combat.energy == energy, "Changing reserve stays free")
	app.open_deck(); await process_frame
	check("Mano: 6 (1 boca abajo)" in app.layer.get_node("DeckSummary").text, "Deck summary includes face-down card in the hand")
	app.back(); await process_frame
	reserved = app.layer.find_child("ReservedCard", true, false)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("pixel_cards/reserved.png"))
	for earlier in [true, false]:
		var play_index = 0 if earlier else app.game.run.combat.hand.size() - 1
		var nodes = app.layer.get_node("CombatHand").get_child(0).get_children()
		var played = nodes.filter(func(node): return int(node.get_meta("hand_index", -1)) == play_index)[0]
		var targets = app.game.valid_targets(play_index)
		app.animate_combat_action(play_index, targets[0])
		check(not played.visible and reserved.visible, "Only the played card turns to ash across reserved slot")
		while app.combat_busy: await process_frame
		await process_frame
		reserved = app.layer.find_child("ReservedCard", true, false)
		check(reserved.get_parent().get_child(app.game.run.combat.reserved_index) == reserved, "Reserved position follows remaining cards")
	app.animate_combat_action()
	check(reserved.visible and reserved.has_node("CardBackCover"), "Reserved card survives outgoing hand ash animation")
	while app.combat_busy: await process_frame
	await process_frame
	check(app.game.run.combat.hand.size() == 7 and app.game.run.combat.hand[0] == replacement, "Next turn restores reserved card alongside normal draw")
	check(app.layer.find_child("ReservedCard", true, false) == null, "Reserved slot clears")
	var hand = app.layer.find_child("CombatHand", true, false).get_child(0)
	check(hand.get_child_count() == 7, "All returned and drawn cards rendered")
	check(hand.get_child(0).get_node_or_null("CardBackCover") == null, "Returned card is face up after reveal")
	# Front/back gallery, using production renderer and real textures.
	app.layer.hide()
	var gallery = Control.new()
	app.add_child(gallery)
	var index = 0
	for hero in ["warrior", "guardian", "rogue", "mage"]:
		var id = ""
		for key in app.game.content.cards:
			if app.game.content.cards[key].owner == hero:
				id = key
				break
		var card = app.card_panel({"id":id,"upgraded":false}, 22 + index * 312, 12, 240, 360, func(): pass, false, true, gallery)
		check(card.get_node("CardCategory").text.length() > 0, "Runtime category: " + hero)
		check(not card.has_node("CardOwner"), "No redundant owner plaque: " + hero)
		var back = TextureRect.new()
		back.texture = load("res://assets/cards/backs/%s.png" % hero)
		back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		app.rect(back, 22 + index * 312, 390, 200, 300, gallery)
		index += 1
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("pixel_cards/fronts_backs.png"))
	gallery.free()
	app.free()
	print("PIXEL CARDS UI: ", checks, " checks, ", failures, " failures")
	quit(1 if failures else 0)

func click(point: Vector2) -> void:
	var motion = InputEventMouseMotion.new()
	motion.position = point
	Input.parse_input_event(motion)
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame
