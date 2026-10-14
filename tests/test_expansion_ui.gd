extends SceneTree
const Game = preload("res://src/game.gd")
var app: Control
var checks = 0
var failures = 0
func _initialize(): call_deferred("run_tests")
func check(ok: bool, caption: String):
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",caption)
func capture(id: String):
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("expansion/"+id+".png"))
func mouse(point: Vector2, pressed: bool):
	var event = InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=pressed;event.position=point;root.push_input(event)
	await process_frame
func move(point: Vector2):
	var event=InputEventMouseMotion.new();event.position=point;event.button_mask=MOUSE_BUTTON_MASK_LEFT;root.push_input(event)
	await process_frame
func run_tests():
	root.size = Vector2i(1280,720)
	app=load("res://main.tscn").instantiate();app.game=Game.new("user://unused-expansion-ui.save",false)
	root.add_child(app);await process_frame
	app.game.new_run(["warrior","guardian"],29,{},3);app.game.enter_node(0)
	app.game.run.combat.hand=[{"id":"warrior_slash","upgraded":false}]
	# Find the actual first attack ID rather than relying on historical card names.
	app.game.run.combat.hand[0].id=app.game.run.deck[0].id
	for enemy in app.game.run.combat.enemies: enemy.hp=200;enemy.max_hp=200
	app.continue_run();await process_frame
	await capture("fortress-combat")
	var drag=app.layer.get_node("CardDrag")
	var card=app.layer.get_node("CombatHand").get_child(0).get_child(0)
	var start=card.get_global_rect().get_center()
	var target_index=app.game.valid_targets(0)[0]
	var target=app.layer.get_node("EnemyTarget%d" % target_index).get_global_rect().get_center()
	var energy=app.game.run.combat.energy
	await mouse(start,true);await move(target)
	check(drag.dragging,"mouse lifts card")
	check(drag.hover_target==target_index,"mouse recognizes eligible enemy")
	check(app.game.run.combat.energy==energy,"lifting does not spend energy")
	await capture("drag-preview")
	await mouse(target,false)
	check(app.game.run.combat.energy < energy,"drop commits instant energy")
	while app.combat_busy: await process_frame
	app.game.run.combat.hand=[app.game.run.deck[0].duplicate(true)];app.render();await process_frame
	drag=app.layer.get_node("CardDrag");card=app.layer.get_node("CombatHand").get_child(0).get_child(0)
	var snapshot=app.game.run.duplicate(true)
	await mouse(card.get_global_rect().get_center(),true);await move(Vector2(1245,700));await mouse(Vector2(1245,700),false)
	check(app.game.run==snapshot,"invalid drop preserves hand/energy")
	# Touch uses its own index and canvas positions, without relying on hover.
	app.render();await process_frame;drag=app.layer.get_node("CardDrag");card=app.layer.get_node("CombatHand").get_child(0).get_child(0)
	var press=InputEventScreenTouch.new();press.index=2;press.pressed=true;press.position=card.get_global_rect().get_center();root.push_input(press); await process_frame
	var motion=InputEventScreenDrag.new();motion.index=2;motion.position=target;root.push_input(motion); await process_frame
	check(drag.dragging and drag.hover_target==target_index,"touch supports target and preview")
	var touch_energy = app.game.run.combat.energy
	var release=InputEventScreenTouch.new(); release.index=2;release.pressed=false;release.position=target;root.push_input(release);await process_frame
	check(app.game.run.combat.energy < touch_energy,"touch release spends energy once")
	while app.combat_busy: await process_frame
	app.game.run.combat.hand=[app.game.run.deck[0].duplicate(true)]
	# A tap still selects, independently from drag-and-drop.
	app.render(); await process_frame
	card=app.layer.get_node("CombatHand").get_child(0).get_child(0)
	await mouse(card.get_global_rect().get_center(),true); await mouse(card.get_global_rect().get_center(),false)
	check(app.selected_card == 0,"tap selects without playing")
	app.selected_card=-1
	# Self defense can only be dropped on its owner, not the companion.
	var defense = app.game.content.cards.keys().filter(func(id): return app.game.content.cards[id].owner == "warrior" and app.game.content.cards[id].target == "self" and app.game.content.cards[id].block > 0)[0]
	app.game.run.combat.hand=[{"id":defense,"upgraded":false}]; app.game.run.combat.energy=3
	app.render(); await process_frame
	drag=app.layer.get_node("CardDrag"); card=app.layer.get_node("CombatHand").get_child(0).get_child(0)
	await mouse(card.get_global_rect().get_center(),true); await move(app.layer.get_node("HeroTarget1").get_global_rect().get_center())
	check(drag.hover_target == -1,"self defense excludes companion")
	await move(app.layer.get_node("HeroTarget0").get_global_rect().get_center())
	check(drag.hover_target == 0,"self defense recognizes owner")
	drag.cancel()
	app.game.run.combat.energy=0; app.render(); await process_frame
	drag=app.layer.get_node("CardDrag"); card=app.layer.get_node("CombatHand").get_child(0).get_child(0)
	await mouse(card.get_global_rect().get_center(),true); await move(app.layer.get_node("HeroTarget0").get_global_rect().get_center())
	check(drag.hover_target == -1,"no-energy card has no playable drop")
	drag.cancel()
	app.game.run.combat.energy=3
	var group_attack = app.game.content.cards.keys().filter(func(id): return app.game.content.cards[id].owner == "warrior" and app.game.content.cards[id].target == "all_enemies")[0]
	app.game.run.combat.hand=[{"id":group_attack,"upgraded":false}];app.render();await process_frame
	drag=app.layer.get_node("CardDrag");card=app.layer.get_node("CombatHand").get_child(0).get_child(0)
	await mouse(card.get_global_rect().get_center(),true);await move(app.layer.get_node("EnemyTarget1").get_global_rect().get_center())
	check(drag.hover_target == 1 and drag.target_at(app.layer.get_node("HeroTarget0").get_global_rect().get_center()) == -1,"group attack drops on enemies only")
	app.pause_menu()
	check(not drag.dragging and card.modulate.a == 1.0,"menu cancels dragging and restores card")
	app.close_modal()
	app.screen="options";app.render();await process_frame
	check(app.layer.has_node("CombatSpeed") and app.layer.has_node("AmbienceVolume"),"comfort options")
	await capture("options")
	app.set_option("text_scale",1.12);app.render();await process_frame
	check(app.theme.default_font_size == 22,"large text scales shared theme")
	await capture("options-large");app.set_option("text_scale",1.0)
	app.game.profile.bonds={"guardian_warrior":1};app.screen="bonds";app.render();await process_frame
	await capture("bonds")
	app.game.run.phase="room";app.game.run.nodes[app.game.run.current].kind="event";app.game.run.nodes[app.game.run.current].event="forest_spring";app.continue_run();await process_frame
	check(app.layer.has_node("EncounterScreen"),"themed encounter")
	await capture("forest-event")
	app.game.run.phase="event_cards";app.game.run.card_event="remove";app.continue_run();await process_frame
	check(app.layer.has_node("ConfirmEventCard"),"deck decision screen")
	await capture("event-cards")
	for id in ["forest_hunter","forest_spirit","forge_altar","ash_archive","lava_bridge"]:
		app.game.run.phase="room";app.game.run.nodes[app.game.run.current].event=id;app.continue_run();await process_frame
		await capture(id)
	app.game.run.nodes[app.game.run.current].kind="rest";app.game.run.floor=3;app.continue_run();await process_frame
	await capture("fortress-rest")
	app.game.run.phase="combat";app.game._start_combat(["volcano_boss","ash_shielder"])
	app.game.run.combat.enemies[0].hp=90;app.game._check_combat_end();app.continue_run();await process_frame
	await capture("guardian-phase-two")
	preload("res://src/ui/screens/run_setup_screen.gd").open(app,3,func(_floor): pass);await process_frame
	await capture("run-setup");app.close_modal()
	preload("res://src/ui/tutorial_navigation.gd").open(app);await process_frame
	await capture("tutorial");app.close_modal()
	app.game.end_adventure();app.continue_run();await process_frame
	await capture("summary")
	app.queue_free();await process_frame;await create_timer(0.3).timeout
	print("EXPANSION UI: %d checks / %d failures"%[checks,failures]);quit(1 if failures else 0)
