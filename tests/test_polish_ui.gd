extends SceneTree
const Game=preload("res://src/game.gd")
var app: Control
var checks=0
var failures=0
var clipping: Array=[]
var captures: Array=[]
var frame_samples: Dictionary={}
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool,caption: String) -> void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",caption)
func inspect(node: Node,screen_id: String) -> void:
	if node is Label and node.is_visible_in_tree() and node.has_meta("intended_size"):
		var intended: Vector2=node.get_meta("intended_size")
		if node.size.y>intended.y+3:clipping.append({"screen":screen_id,"path":str(node.get_path()),"text":node.text,"height":node.size.y,"intended":intended.y})
	for child in node.get_children():inspect(child,screen_id)
func capture(id: String) -> void:
	await process_frame;await create_timer(0.16).timeout
	inspect(app.layer,id)
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("polish/"+id+".png"))
	captures.append(id)
func show(screen: String,id: String="") -> void:
	app.screen=screen;app.render();await capture(screen if id=="" else id)
func key(code: Key) -> void:
	var event=InputEventKey.new();event.keycode=code;event.pressed=true;root.push_input(event);await process_frame
func joy(button: JoyButton) -> void:
	var event=InputEventJoypadButton.new();event.button_index=button;event.pressed=true;root.push_input(event);await process_frame
func run_tests() -> void:
	root.size=Vector2i(1280,720)
	app=load("res://main.tscn").instantiate();app.game=Game.new("user://unused-polish-ui",false);app.game.profile.tutorial_complete=true
	root.add_child(app);await process_frame
	app.game.profile.buildings={"market":true,"forge":true,"church":true,"expeditions":true}
	app.game.profile.specializations.victorious=app.game.content.heroes.keys()
	app.game.profile.bestiary={"skeleton":{"encounters":1,"kills":1},"rat":{"encounters":1,"kills":0},"ice_elemental":{"encounters":1,"kills":0}}
	for id in app.game.content.heroes:app.game.profile.forge_upgrades[id]={"weapon":3,"armor":3}
	await show("home");await show("options");await show("base_camp");await show("projects")
	await show("market");app.market_hero="warrior";await show("market","market-cards")
	app.market_hero="";await show("forge");app.forge_hero="guardian";await show("forge","forge-detail")
	await show("church");app.church_hero="guardian";await show("church","church-detail")
	await show("expeditions");await show("refuge")
	var refuge=app.layer.get_node("RefugeScreen");refuge.selected="rogue";refuge.redraw();await capture("refuge-comparison")
	await show("select");app.selected_party=["warrior","guardian"];app.equipped={"team":"vital_amulet"};await show("equipment")
	await show("training_setup");preload("res://src/ui/screens/training_config_dialog.gd").open(app);await capture("training-config");app.close_modal()
	await show("collection");await show("bestiary")
	for floor_number in [1,2,3]:
		app.game.new_run(["warrior","guardian"],141,{},floor_number);await show("map","map-%d" % floor_number)

	var risk=app.game.run.nodes.filter(func(n):return n.has("risk"))[0]
	app.game.run.current=app.game.run.nodes.filter(func(n):return risk.id in n.next)[0].id
	await show("map","risk-map");var snapshot=app.game.run.duplicate(true)
	preload("res://src/ui/map_room_prompt.gd").enter(app,risk.id);await capture("risk-confirmation")
	check(app.game.run==snapshot and is_instance_valid(app.overlay),"touch risk prompt does not enter before confirmation")
	app.close_modal();app.game.run.current=-1
	app.game.enter_node(0);app.game._start_combat(["skeleton","rat","ice_elemental"]);await show("combat","combat-triple")
	app.game.run.combat.hand=[{"id":"warrior_slash","upgraded":false}]
	app.selected_card=-1;app.render();await process_frame
	await key(KEY_1);check(app.selected_card==0,"keyboard selects card")
	await key(KEY_DOWN);check(app.keyboard_target in app.game.valid_targets(0),"keyboard selects validated target")
	var energy=int(app.game.run.combat.energy);await key(KEY_ENTER)
	check(app.combat_busy and app.game.run.combat.energy==energy-1,"keyboard commits once and spends instantly")
	while app.combat_busy:await process_frame
	app.game.run.combat.hand=[{"id":"guardian_strike","upgraded":false}];app.selected_card=-1;app.render();await process_frame
	await joy(JOY_BUTTON_RIGHT_SHOULDER)
	check(app.selected_card==0,"gamepad selects card")
	await joy(JOY_BUTTON_DPAD_DOWN);energy=int(app.game.run.combat.energy);await joy(JOY_BUTTON_A)
	check(app.combat_busy and app.game.run.combat.energy==energy-1,"gamepad selects target and commits once")
	while app.combat_busy:await process_frame
	var recipe=app.game.content.synergies[0];app.game.new_run(recipe.heroes,41);app.game.enter_node(0)
	app.game.run.combat.hand=[]
	for id in recipe.cards:app.game.run.combat.hand.append({"id":id,"upgraded":false})
	for enemy in app.game.run.combat.enemies:enemy.hp=500;enemy.max_hp=500
	app.selected_card=-1;app.render();await process_frame;await key(KEY_L)
	check(app.selected_synergy==recipe.id,"keyboard selects available link")
	await key(KEY_ENTER)
	check(app.combat_busy and app.game.run.combat.energy==1 and app.game.run.combat.hand.is_empty(),"keyboard link consumes two cards and real energy")
	while app.combat_busy:await process_frame
	app.game.new_run(["warrior","guardian"],141,{},3);app.game.enter_node(0);app.game._start_combat(["skeleton","rat","ice_elemental"])

	app.selected_card=-1;app.render();await process_frame
	var times: Array=[];var deadline=Time.get_ticks_msec()+3000;var previous=Time.get_ticks_usec()
	while Time.get_ticks_msec()<deadline:
		await process_frame;var now=Time.get_ticks_usec();times.append((now-previous)/1000.0);previous=now
	times.sort();frame_samples={"frames":times.size(),"p50_ms":times[int(times.size()*0.5)],"p95_ms":times[int(times.size()*0.95)],"p99_ms":times[int(times.size()*0.99)]}
	await show("deck");await show("items")
	app.game.run.phase="merchant";preload("res://src/rules/travel_encounters.gd").prepare(app.game);await show("merchant")
	var rest=app.game.run.nodes.filter(func(n):return n.kind=="rest")[0];app.game.run.current=rest.id;app.game.run.phase="room";await show("room","rest")
	var encounter=app.game.run.nodes.filter(func(n):return n.kind=="event")[0];app.game.run.current=encounter.id
	for id in ["well","pact_blood","pair_guardian_warrior"]:encounter.event=id;app.game.run.phase="room";await show("room","event-"+id)
	var boss=app.game.run.nodes.filter(func(n):return n.kind=="boss")[0];app.game.run.current=boss.id;app.game._start_combat(boss.encounter);await show("combat","boss-objective")
	var objective_energy=int(app.game.run.combat.energy);await key(KEY_O)
	check(app.game.run.combat.energy==objective_energy-1 and app.game.run.combat.boss_objective.hp==1,"keyboard objective action spends real energy")
	await joy(JOY_BUTTON_X)
	check(app.game.run.combat.energy==objective_energy-2 and app.game.run.combat.boss_objective.broken,"gamepad objective destroys final plate")
	app.game.run.boss_defeated=true;app.game._make_reward();await show("reward")
	app.game.choose_reward(-1);await show("boss_reward")
	check(app.layer.find_child("BossRelic_fire_crown",true,false) != null,"three exclusive relics rendered")
	var original=app.game;var profile=original.profile.duplicate(true);var run=original.run.duplicate(true)
	app.training_config={"enemies":["skeleton","rat"],"mode":"custom","damage":8,"block":4,"counter":true}
	preload("res://src/ui/training_navigation.gd").start(app,["mage","rogue"],2,1);await capture("training-group")
	check(app.game.run.combat.enemies.size()==2 and app.game.run.combat.enemies.all(func(e):return e.intent.block==4 and e.intent.damage==8 and e.intent.counter==4),"custom group intentions")
	preload("res://src/ui/training_navigation.gd").leave(app)
	check(app.game==original and app.game.profile==profile and app.game.run==run,"training restores exact original state")
	var report={"captures":captures,"clipping":clipping,"checks":checks,"failures":failures,"frame_samples":frame_samples,"renderer":RenderingServer.get_video_adapter_name(),"memory_mib":Performance.get_monitor(Performance.MEMORY_STATIC)/1048576.0,"texture_mib":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)/1048576.0}
	var file=FileAccess.open(preload("res://tests/artifacts.gd").path("polish/ui-audit.json"),FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t")+"\n")
	app.queue_free();await process_frame
	await create_timer(0.15).timeout
	print("POLISH UI: ",checks," checks / ",failures," failures · ",captures.size()," views")
	quit(1 if failures>0 else 0)
