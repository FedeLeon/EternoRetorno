extends SceneTree
const Game=preload("res://src/game.gd")
var checks=0
var failures=0
func check(ok: bool, caption: String) -> void:
	checks+=1
	if not ok: failures+=1;printerr("FAIL: ",caption)
func battle(party: Array=["warrior","guardian"],floor_number: int=1) -> RefCounted:
	var g=Game.new("user://unused-polish",false);g.new_run(party,331,{},floor_number);g.enter_node(0)
	for enemy in g.run.combat.enemies:enemy.hp=500;enemy.max_hp=500;enemy.intent={"damage":0,"block":0,"counter":0,"target":0}
	return g
func hand(g: RefCounted,id: String) -> void: g.run.combat.hand=[{"id":id,"upgraded":false}];g.run.combat.energy=3
func boss(floor_number: int) -> RefCounted:
	var g=battle(["warrior","guardian"],floor_number)
	var node=g.run.nodes.filter(func(n):return n.kind=="boss")[0]
	g.run.current=node.id;g._start_combat(node.encounter)
	return g
func _initialize() -> void:
	var g=battle();hand(g,"warrior_risk");var hp=int(g.run.heroes[0].hp)
	check(g.play_card(0,0) and g.run.heroes[0].hp==hp-5 and g.run.combat.energy==5,"blood cost and energy commit together")
	hand(g,"warrior_risk");g.run.heroes[0].hp=5;var before=g.run.duplicate(true)
	check(not g.play_card(0,0) and g.run==before,"health cost cannot kill and rejected play changes nothing")
	g=battle(["warrior", "rogue"]);hand(g,"rogue_risk");before=g.run.duplicate(true)
	check(not g.play_card(0,0) and g.run==before,"discard card needs another card")
	g.run.combat.hand.append({"id":"rogue_risk","upgraded":false})
	check(g.play_card(0,0) and g.run.combat.hand.is_empty() and g.run.combat.discard.size()==2,"rightmost companion card discarded exactly once")
	g=battle(["guardian", "mage"]);hand(g,"guardian_risk");before=g.run.duplicate(true)
	check(not g.play_card(0,0) and g.run==before,"guard sacrifice needs six block")
	g.run.heroes[0].block=7;check(g.play_card(0,0) and g.run.heroes[0].block==1,"guard sacrifice pays six")
	for floor_number in [1,2,3]:
		g=boss(floor_number)
		check(g.run.combat.has("boss_objective"),"boss objective floor %d" % floor_number)
		g.run.phase="reward";g.run.reward=[];g.run.boss_defeated=true
		check(g.choose_reward(-1) and g.run.phase=="boss_reward" and g.run.boss_offers.size()==3,"three exclusive boss choices")
		var id: String=g.run.boss_offers[0]
		before=g.run.duplicate(true);var previous_rng=g.rng.state
		check(not g.polish_action("boss_relic",{"id":"invalid"}) and g.run==before and g.rng.state==previous_rng,"invalid relic cannot advance floor")
		check(g.polish_action("boss_relic",{"id":id}) and id in g.run.relics and id in g.profile.boss_relics and g.run.phase=="map","one boss relic granted")
		check(g.run.floor==mini(floor_number+1,3),"boss relic automatically opens next dungeon")
		if floor_number<3:
			check(g.run.current==-1 and g.available_nodes()==[0,1,2] and not g.run.boss_defeated,"next dungeon ready at entrance")
			check(not g.descend(),"transition cannot skip an unbeaten dungeon")
		before=g.run.duplicate(true);check(not g.polish_action("boss_relic",{"id":id}) and g.run==before,"boss reward cannot repeat")
	g=boss(1);g.run.combat.energy=3;check(g.polish_action("boss_objective") and g.run.combat.boss_objective.hp==10,"source first strike")
	check(g.polish_action("boss_objective") and g.run.combat.boss_objective.broken,"source destroyed")
	check(not g.polish_action("boss_objective") and g.run.combat.energy==1,"destroyed source cannot charge again")
	g=boss(1);var enemy=g.run.combat.enemies[0];enemy.hp=0
	check(not g._check_combat_end() and enemy.hp>0 and g.run.combat.boss_objective.revival_used,"unbroken source revives guardian once")
	enemy.hp=0;check(g._check_combat_end() and g.run.phase=="reward","second death finishes fight")
	g=boss(2);g.run.combat.boss_objective.trapped=0;hand(g,"warrior_slash")
	check(g.valid_targets(0).is_empty(),"trapped hero cannot play")
	check(g.polish_action("boss_objective") and not g.valid_targets(0).is_empty(),"one energy frees companion")
	g.run.combat.boss_objective.trapped=0;g.run.combat.boss_objective.released_turn=g.run.combat.turn;g.run.combat.turn+=1
	preload("res://src/rules/boss_mechanics.gd").new_turn(g);check(g.run.combat.boss_objective.trapped==-1,"prison expires without spending energy")
	g=boss(3);enemy=g.run.combat.enemies[0]
	check(preload("res://src/rules/boss_mechanics.gd").hit(g,enemy,20,false)==10,"armor halves direct damage")
	preload("res://src/rules/boss_mechanics.gd").hit(g,enemy,20,true);preload("res://src/rules/boss_mechanics.gd").hit(g,enemy,20,true)
	check(g.run.combat.boss_objective.broken and preload("res://src/rules/boss_mechanics.gd").hit(g,enemy,20,false)==20,"piercing removes plates and exposes boss")
	g=battle();var choices=preload("res://src/rules/adventure_choices.gd")

	g=battle(["guardian", "mage"],2);g.run.combat.boss_objective={"trapped":0};g.run.combat.hand=[{"id":"guardian_guard","upgraded":false},{"id":"guardian_strike","upgraded":false}]
	check(g.synergy_targets("whatever").is_empty(),"trapped partner cannot participate in synergy")
	g=battle()
	check(JSON.parse_string(FileAccess.get_file_as_string("res://data/pair_events.json")).size()==6,"one event per hero pair")
	var risky: Array=g.run.nodes.filter(func(n):return n.has("risk"))
	check(risky.size()==1 and g.run.nodes.any(func(n):return n.stage==risky[0].stage and not n.has("risk")),"risk branch has ordinary alternative")

	for parent in g.run.nodes:
		if risky[0].id in parent.next: check(parent.next.any(func(id):return id!=risky[0].id),"every risk entrance has safe exit")
	g.run.phase="room";g.run.nodes[g.run.current].kind="event";g.run.nodes[g.run.current].event="pact_blood"
	check(g.choose_event(0) and g.run.curses==["blood"] and g.run.relics.size()==1,"pact has reward and explicit curse")
	g.run.phase="merchant";hp=int(g.profile.souls);check(g.polish_action("cleanse") and g.run.curses.is_empty() and g.profile.souls==hp-35,"merchant cleanse charges once")
	check(not g.polish_action("cleanse"),"no payment without curse")
	g=battle();var state=g.rng.state;hand(g,"warrior_slash");g.play_card(0,0)
	check(g.rng.state==state and g.run.telemetry.cards.warrior_slash==1,"telemetry never consumes gameplay RNG")
	g=battle(["warrior","guardian"],2);g._start_combat(["forest_wolf","goblin_shaman"])
	var coordination=preload("res://src/rules/enemy_coordination.gd")
	var wolf=g.run.combat.enemies[0];var shaman=g.run.combat.enemies[1]
	var base_damage=int(wolf.intent.damage)
	check(coordination.intent(g,wolf).damage==base_damage+3,"beast intent includes living support damage before round starts")
	var incoming=0
	for unit in g.run.combat.enemies:
		unit.intent.target=0;unit.intent.all=false;incoming+=coordination.intent(g,unit).damage
	for hero in g.run.heroes:hero.block=0
	hp=int(g.run.heroes[0].hp);g.end_turn()
	check(g.run.heroes[0].hp==hp-incoming,"actual coordinated damage equals displayed intentions")
	base_damage=int(wolf.intent.damage);shaman.hp=0
	check(coordination.intent(g,wolf).damage==base_damage,"killing support immediately removes its predicted bonus")
	var upgraded={"id":"warrior_risk","upgraded":true,"upgrade_variant":"efficient","upgrade_rules":2}
	check(g.content.card(upgraded).hits==1,"new free efficiency does not multiply hits")
	var config={"enemies":[g.run.combat.enemies[0].id],"mode":"custom","damage":12,"block":7,"counter":true}
	check(preload("res://src/rules/training_config.gd").validate(g,config),"training accepts discovered enemy")
	check(not preload("res://src/rules/training_config.gd").validate(g,{"enemies":["unknown"]}),"training rejects unknown enemy")
	var save_path="user://polish-resume.save";var saved=Game.new(save_path,true);saved.profile=g.profile.duplicate(true);saved.run=g.run.duplicate(true);saved.checkpoint()
	var restored=Game.new(save_path,true);check(restored.run==saved.run,"new state survives save reload")
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(save_path+suffix)
	print("POLISH RULES: ",checks," checks / ",failures," failures")
	quit(1 if failures>0 else 0)
