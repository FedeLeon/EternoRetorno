extends SceneTree
const Game = preload("res://src/game.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",message)
func shot(name: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("adaptive_hand/"+name+".png"))
func contained(hand: Control, cards: Array) -> void:
	var area=hand.get_global_rect().grow(.1)
	for card in cards:
		for corner in [Vector2.ZERO,Vector2(card.size.x,0),card.size,Vector2(0,card.size.y)]:
			check(area.has_point(card.get_global_transform()*corner),"rotated card corner remains visible")
func verify() -> void:
	root.size=Vector2i(1280,720)
	var app=load("res://main.tscn").instantiate()
	app.game=Game.new("user://unused-adaptive-hand",false)
	app.game.profile.tutorial_complete=true
	root.add_child(app)
	app.game.new_run(["rogue","mage"],41);app.game.enter_node(0)
	var b=app.game.run.combat
	var sample=b.hand[0].duplicate(true)
	var previous=1.0
	for count in [1,6,7,8,10,12]:
		b.hand.clear();b.reserved=[];app.selected_card=-1
		for i in range(count):b.hand.append(sample.duplicate(true))
		app.hand_scroll=300
		var state=app.game.run.duplicate(true)
		app.continue_run();await process_frame;await process_frame
		var hand=app.layer.get_node("CombatHand")
		var cards=hand.get_child(0).get_children()
		check(cards.size()==count,"all cards rendered: "+str(count))
		check(hand.scroll_horizontal==0 and hand.get_child(0).size.x<=hand.size.x,"no offscreen scroll area")
		check(cards[0].scale.x<=previous,"larger hands progressively reduce cards")
		previous=cards[0].scale.x
		if count>6:
			check(previous<1,"extra cards reduce size")
			contained(hand,cards)
		else:check(cards[0].scale==Vector2.ONE,"normal hands retain their size")
		check(app.game.run==state,"arrangement leaves combat state unchanged")
		if count in [7,10]:await shot(str(count)+"-cards")
		var point=cards[-1].get_global_transform()*Vector2(60,45)
		for pressed in [true,false]:
			var click=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.pressed=pressed;click.position=point;root.push_input(click)
		await process_frame
		check(app.selected_card==count-1,"last card remains selectable: "+str(count))
		var selected=app.layer.get_node("CombatHand").get_child(0).get_child(count-1)
		check(selected.scale==Vector2.ONE and selected.rotation==0,"selected card stays readable at full size")
		if count>6:contained(app.layer.get_node("CombatHand"),[selected])
		if count==7:await shot("selected-last")
	# The face-down card counts toward the total and keeps its compact width after a flip.
	b.hand.clear()
	for i in range(7):b.hand.append(sample.duplicate(true))
	b.reserved=[sample.duplicate(true)];b.reserved_index=3;app.selected_card=-1
	app.render();await process_frame
	var hand=app.layer.get_node("CombatHand")
	contained(hand,hand.get_child(0).get_children())
	var reserved=app.layer.find_child("ReservedCard",true,false)
	var before=reserved.scale
	await preload("res://src/presentation/card_flip.gd").play(reserved,preload("res://src/ui/card_reserve_navigation.gd").back_for(app,sample),true)
	check(reserved.scale.is_equal_approx(before),"flip restores compact scale on both axes")
	contained(hand,[reserved]);await shot("reserved")
	app.queue_free();await process_frame
	print("ADAPTIVE HAND: %d checks / %d failures"%[checks,failures]);quit(1 if failures else 0)
