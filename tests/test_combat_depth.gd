extends SceneTree
const Game=preload("res://src/game.gd")
const Depth=preload("res://src/rules/combat_depth.gd")
var checks=0;var failures=0
func check(ok: bool, caption: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",caption)
func game(floor_number: int=1) -> RefCounted:
	var g=Game.new("user://unused-depth",false);g.new_run(["warrior","guardian"],81,{},floor_number);g.enter_node(0)
	return g
func hand(g: RefCounted,id: String):
	g.run.combat.hand=[{"id":id,"upgraded":false}];g.run.combat.energy=99
func _initialize():
	var g=game()
	var enemy=g.run.combat.enemies[0];enemy.hp=300;enemy.max_hp=300;enemy.intent={"damage":0,"block":0,"counter":0,"target":0}
	hand(g,"warrior_prepared");var hp=enemy.hp;var energy=g.run.combat.energy
	check(g.play_card(0,0) and enemy.hp==hp and g.run.combat.energy==energy-1,"charge spends now without damage")
	check(g.run.combat.prepared.size()==1,"charge queue stored")
	g.end_turn()
	# Counterattacks are separate receipts, not additional prepared hits.
	var prepared_hits=g.resolved_prepared_hits.filter(func(event):return event.kind=="hit")
	check(enemy.hp==hp-17 and prepared_hits.size()==1 and g.run.combat.prepared.is_empty(),"charge hits once next turn")
	var save_path="user://depth-charge-test.save";var store=Game.new(save_path,true)
	store.new_run(["warrior","guardian"],81);store.enter_node(0);store.run.combat.enemies[0].hp=300;store.run.combat.enemies[0].max_hp=300
	hand(store,"warrior_prepared");store.play_card(0,0)
	var restored=Game.new(save_path,true)
	check(restored.run.combat.prepared==store.run.combat.prepared,"charge survives save reload")
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(save_path+suffix)
	enemy.intent={"damage":0,"block":0,"counter":4,"target":0,"special":"resurrect"}
	hand(g,"warrior_interrupt");var hero_hp=g.run.heroes[0].hp
	check(g.play_card(0,0) and not enemy.intent.has("special") and enemy.intent.counter==0 and g.run.heroes[0].hp==hero_hp,"interrupt special and counter before hit")
	g._start_combat(["ice_elemental","crypt_lancer_new"])
	hand(g,"warrior_slash")
	check(g.valid_targets(0)==[0],"protector hides rear from melee")
	g.run.combat.hand=[{"id":"guardian_strike","upgraded":false}]
	var caster_id=g.content.cards.keys().filter(func(id):return g.content.cards[id].owner=="guardian" and g.content.cards[id].target=="enemy")[0]
	g.run.combat.hand[0].id=caster_id
	# Constructora is melee for coverage; only rogue/mage, area and pierce bypass.
	var card=g.content.card(g.run.combat.hand[0]);card.pierce=true
	check(Depth.targets(g,card,[0,1])==[0,1],"piercing bypasses protector")
	g.run.combat.enemies[0].hp=0;hand(g,"warrior_slash")
	check(g.valid_targets(0)==[1],"rear opens after protector death")
	g=game(2);enemy=g.run.combat.enemies.back();enemy.root_hp=10;hp=enemy.hp
	hand(g,"warrior_slash");g.play_card(0,g.run.combat.enemies.size()-1)
	check(enemy.hp==hp and enemy.root_hp==1,"roots absorb first hit")
	hand(g,"warrior_slash");g.play_card(0,g.run.combat.enemies.size()-1)
	check(enemy.hp==hp and enemy.root_hp==0,"roots destroyed before life damage")
	hand(g,"warrior_slash");g.play_card(0,g.run.combat.enemies.size()-1)
	check(enemy.hp<hp,"enemy exposed after roots")
	g=game(3);enemy=g.run.combat.enemies[0];enemy.hp=300;enemy.max_hp=300
	for e in g.run.combat.enemies:e.intent={"damage":0,"block":0,"target":0}
	g.end_turn();check(enemy.intent.get("special","")=="embers","fortress announces embers")
	hand(g,"warrior_interrupt");var target=g.valid_targets(0)[0];var interrupted=g.run.combat.enemies[target];g.play_card(0,target);check(not interrupted.intent.has("special"),"embers interruptible")
	g=game();g._start_combat(["skeleton","crypt_lancer_new"]);g.run.combat.enemies[1].hp=0
	g.run.combat.turn=3;enemy=g.run.combat.enemies[0];enemy.intent={"damage":0,"block":0,"target":0}
	Depth.plan(g,enemy,enemy.intent);check(enemy.intent.get("special","")=="resurrect","crypt telegraphs revival")
	Depth.action(g,enemy,enemy.intent);check(g.run.combat.enemies[1].hp>0 and g.run.combat.enemies[1].resurrected,"revive once")
	g.run.combat.enemies[1].hp=0;enemy.intent.erase("special");Depth.plan(g,enemy,enemy.intent)
	check(not enemy.intent.has("special"),"no infinite corpse revival")
	var original=g.content.card({"id":"warrior_slash","upgraded":true})
	var efficient=g.content.card({"id":"warrior_slash","upgraded":true,"upgrade_variant":"efficient"})
	check(original.damage==12 and efficient.damage==9 and efficient.cost==0,"legacy power and alternate efficiency")
	var healing=g.content.cards.keys().filter(func(id):return g.content.cards[id].owner=="guardian" and g.content.cards[id].heal>0 and g.content.cards[id].target=="ally")[0]
	check(g.content.card({"id":healing,"upgraded":true,"upgrade_variant":"shared"}).target=="all_allies","shared healing choice")
	g.run.phase="merchant";preload("res://src/rules/travel_encounters.gd").prepare(g);g.profile.souls=100
	var offer=g.run.merchant_offers[0];var souls=g.profile.souls
	check(g.merchant_action("buy",0) and g.profile.souls==souls-offer.price and g.run.inventory[offer.item]==1,"merchant item purchase")
	check(not g.merchant_action("buy",0),"merchant offer cannot be purchased twice")
	g.run.relics=["fang"];check(g.merchant_action("trade",0) and g.run.relics.size()==1,"relic exchange replaces exact relic")
	check(not g.merchant_action("trade",0),"relic exchange one time")
	g.merchant_action("leave");check(g.run.phase=="map","merchant returns to route")
	g=game();preload("res://src/rules/travel_encounters.gd").chain(g,"library")
	preload("res://src/rules/travel_encounters.gd").apply_room(g,"treasure")
	check(g.run.inventory.healing_potion==1 and not g.run.event_flags.knowledge,"chain consequence consumed once")
	check(not g.run.combat.get("journal",[]).is_empty(),"damage/effects journal populated")
	g.run.relics=["fang","storm_drum"]
	check(preload("res://src/rules/relic_sets.gd").active(g.run).size()==1,"relic pair activation")
	g._finish(false)
	check(g.profile.history[0].deck.size()==20 and g.profile.history[0].relics.size()==2,"final deck and relics retained in history")
	check(g.profile.get("bestiary",{}).size()>0,"encounters recorded in bestiary")
	print("COMBAT DEPTH: %d checks / %d failures"%[checks,failures]);quit(1 if failures else 0)
