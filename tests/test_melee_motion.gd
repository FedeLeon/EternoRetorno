extends SceneTree
const Flow = preload("res://src/ui/combat_flow.gd")
const Motion = preload("res://src/presentation/melee_motion.gd")
var checks = 0
var failures = 0
func _initialize(): call_deferred("verify")
func check(ok: bool, message: String):
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",message)
func verify():
	root.size=Vector2i(1280,720)
	var app=load("res://main.tscn").instantiate()
	app.game=preload("res://src/game.gd").new("user://unused-melee-test",false)
	root.add_child(app)
	for hero in ["warrior","guardian","rogue","mage"]:
		check(Motion.applies({"damage":5},hero)==(hero in ["warrior","guardian","rogue"]),"delivery classification " + hero)
	check(not Motion.applies({"damage":0},"warrior"),"nonoffensive cards stay in place")
	check(not Motion.applies({"damage":5,"id":"rogue_plague"},"rogue"),"poison outbreak is ranged")
	var cases=[
		["warrior","warrior_slash",0,1.0,false],
		["guardian","guardian_bash",2,1.0,false],
		["rogue","rogue_double_fang",0,1.0,false],
		["warrior","warrior_onslaught",0,1.0,false],
		["warrior","warrior_cleave",0,2.0,false],
		["warrior","warrior_slash",2,2.0,true],
		["mage","mage_spark",0,1.0,false],
		["rogue","rogue_cut",0,1.0,false]]
	for item in cases:
		var hero: String=item[0]
		app.game.profile.settings={"combat_speed":item[3],"reduce_cutins":item[4]}
		app.apply_options()
		app.game.new_run([hero,"mage" if hero == "guardian" else "guardian"],31)
		app.game.enter_node(0); app.game._start_combat(["skeleton_warrior","rat","goblin_warrior"])
		for enemy in app.game.run.combat.enemies: enemy.hp=500; enemy.max_hp=500; enemy.intent.counter=0
		if item[1]=="guardian_bash": app.game.run.combat.enemies[item[2]].intent.counter=4
		app.game.run.combat.hand=[{"id":item[1],"upgraded":false}]; app.game.run.combat.energy=10
		app.continue_run(); await process_frame
		var actor: Control=app.hero_art[0]
		var parent=actor.get_parent(); var original=actor.position; var original_scale=actor.scale
		var original_feet=actor.get_global_transform()*Vector2(actor.size.x/2,actor.size.y)
		var health_position=app.hero_health[0].global_position
		var expected_melee=Motion.applies(app.game.content.cards[item[1]],hero)
		Flow.run(app,0,item[2])
		check(app.combat_busy,"legal attack starts " + item[1])
		var committed=app.game.run.duplicate(true)
		var moved=false; var overlap=false; var actions: Dictionary={}; var places: Dictionary={}; var snapped=false
		while app.combat_busy:
			if is_instance_valid(actor):
				var feet=actor.get_global_transform()*Vector2(actor.size.x/2,actor.size.y)
				moved = moved or feet.distance_to(original_feet)>10
				if actor.get_meta("melee_active",false) and actor.sprite.animation in ["thrust","sweep","charged"] and actor.sprite.frame>=2:
					actions[actor.sprite.animation]=true
					places[roundi(feet.x/10)]=true
					check(absf(feet.y-original_feet.y)<0.1,"ground baseline preserved")
					check(actor.scale==original_scale and app.hero_health[0].global_position==health_position,"size and HUD stay fixed")
					var cut=app.layer.get_node_or_null("HeroCutIn")
					overlap=overlap or (cut!=null and cut.modulate.a>0.5)
					if item[4]: check(cut==null,"reduced cut-ins option respected")
					if not snapped and DisplayServer.get_name()!="headless" and (cut!=null or item[4]):
						await RenderingServer.frame_post_draw
						root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("melee/"+item[1]+("-reduced" if item[4] else "")+".png"));snapped=true
			await process_frame
		check(moved==expected_melee,"only melee actors move " + item[1])
		if expected_melee:
			check(not actions.is_empty(),"attack pose at enemy")
			if not item[4]: check(overlap,"HD cut-in overlaps close attack")
			if item[1]=="warrior_cleave": check(places.size()>=3,"area visits all three targets")
			if item[1]=="warrior_onslaught": check(actions.size()==3,"combo keeps three distinct motions")
			if item[1]=="rogue_double_fang": check(actions.size()==2,"combo keeps two distinct motions")
		check(app.game.run==committed,"presentation never changes committed state")
		# Flow rebuilds the arena after the actor returns; old object may be freed.
		if is_instance_valid(actor): check(actor.get_parent()==parent and actor.position==original and actor.scale==original_scale,"actor restored before rebuild")
		check(app.hero_art[0].get_parent().name=="HeroTarget0" and not app.hero_art[0].get_meta("melee_active",false),"normal actor restored after action")
	app.queue_free();await process_frame
	print("MELEE MOTION: %d checks / %d failures" % [checks,failures]);quit(1 if failures else 0)
