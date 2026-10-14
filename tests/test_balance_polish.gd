extends SceneTree
# Deterministic decision bot. Uses real transactions, rewards and upgrades.
# Does not represent human play or replace a device/browser benchmark.
const Game=preload("res://src/game.gd")
var results: Array=[]
var failures=0
func _initialize():
 var heroes=Game.new("user://unused-balance",false).content.heroes.keys()
 for rank in [0,1]:
  for i in range(heroes.size()):
   for j in range(i+1,heroes.size()):
    for seed_value in range(3):
     var g=Game.new("user://unused-balance",false)
     if rank>0:
      for hero in heroes: g.profile.forge_upgrades[hero]={"weapon":rank,"armor":rank}
     g.new_run([heroes[i],heroes[j]],900+seed_value,{"team":"vital_amulet"})
     simulate(g)
     results.append({"party":g.run.party,"seed":g.run.seed,"gear":rank,"won":g.run.phase=="victory","floor":g.run.floor,"telemetry":g.run.telemetry,"killer":g.run.get("killer","")})
 var report={"bot":"Legal greedy actions; selects rewards and upgrades; no battle stats modified","runs":results,"failures":failures}
 var out=FileAccess.open(preload("res://tests/artifacts.gd").path("polish/balance.json"),FileAccess.WRITE);out.store_string(JSON.stringify(report,"\t")+"\n")
 for rank in [0,1]:
  var group=results.filter(func(r):return r.gear==rank)
  print("BALANCE rank ",rank,": ",group.filter(func(r):return r.won).size(),"/",group.size()," wins")
 print("BALANCE: ",results.size()," adventures, ",failures," failures")
 quit(1 if failures else 0)
func quality(g,instance) -> float:
 var c=g.effective_card(instance)
 return float(c.damage*c.hits+c.poison*2+c.heal*2+c.block*0.7)/maxf(1,c.cost)
func simulate(g) -> void:
 var steps=0
 while g.run.phase not in ["victory","defeat"] and steps<2000:
  steps+=1
  match g.run.phase:
   "map":
    if g.run.boss_defeated:g.descend();continue
    var available=g.available_nodes();var next=available[0];var best=-999
    for id in available:
     var n=g.run.nodes[id];var value={"rest":7,"event":6,"treasure":5,"combat":2,"elite":0,"boss":1}.get(n.kind,0)-(4 if n.has("risk") else 0)
     if value>best:best=value;next=id
    g.enter_node(next)
   "room":
    match g.run.nodes[g.run.current].kind:
     "treasure":g.take_treasure();g.leave_treasure()
     "rest":
      if not g.run.get("curses",[]).is_empty():g.polish_action("cleanse");continue
      var wounded=g.run.heroes.any(func(h):return h.hp<h.max_hp*0.7)
      var best=-1;var value=-1.0
      for i in range(g.run.deck.size()):
       if not g.run.deck[i].upgraded and quality(g,g.run.deck[i])>value:best=i;value=quality(g,g.run.deck[i])
      g.rest(wounded or best<0,best)
     "event":
      var id=g.run.nodes[g.run.current].event
      if not g.choose_event(1 if id.begins_with("pact_") else 0):g.choose_event(1)
   "event_cards":g.modify_event_card(-1)
   "merchant":g.merchant_action("leave")
   "reward":
    var best=-1;var value=8.0
    for i in range(g.run.reward.size()):
     var score=quality(g,g.run.reward[i])
     if score>value:best=i;value=score
    g.choose_reward(best)
   "boss_reward":
    var priority={"crypt_blood":3,"crypt_seal":2,"crypt_lantern":1,"forest_thorn":2,"forest_heart":3,"forest_eye":1,"fire_crown":1,"fire_ward":2,"fire_spark":3}
    var best=g.run.boss_offers[0]
    for id in g.run.boss_offers:
     if priority[id]>priority[best]:best=id
    g.polish_action("boss_relic",{"id":best})
   "combat":
    var objective=g.run.combat.get("boss_objective",{})
    if (objective.get("kind","") in ["source","armor"] and not objective.broken) or objective.get("trapped",-1)>=0:
     if g.polish_action("boss_objective"):continue
    # Prefer consumables before lethal incoming damage, using validated item rules.
    if g.run.heroes.any(func(h):return h.hp>0 and h.hp<h.max_hp*0.45) and g.run.inventory.get("healing_potion",0)>0:
     var weakest=0 if float(g.run.heroes[0].hp)/g.run.heroes[0].max_hp<float(g.run.heroes[1].hp)/g.run.heroes[1].max_hp else 1
     if g.use_item("healing_potion",weakest):continue
    var best=-1;var target=-1;var score=-1.0
    for i in range(g.run.combat.hand.size()):
     var c=g.effective_card(g.run.combat.hand[i])
     for t in g.valid_targets(i):
      var q=float(c.damage*c.hits+c.poison*2)/maxf(1,c.cost)
      if c.target=="enemy":
       var enemy=g.run.combat.enemies[t]
       if c.damage*c.hits>=enemy.hp+(0 if c.pierce else enemy.block):q+=30
      if c.target=="all_enemies":q*=g.run.combat.enemies.filter(func(e):return e.hp>0).size()
      if c.target in ["self","ally","all_allies"]:
       var targets=g.living_heroes() if c.target=="all_allies" else [t]
       for hero_index in targets:
        var h=g.run.heroes[hero_index];q+=mini(c.heal,h.max_hp-h.hp)*2.2/maxf(1,c.cost)
        var incoming=0
        for e in g.run.combat.enemies:
         if e.hp>0 and (e.intent.target==hero_index or e.intent.get("all",false)):incoming+=e.intent.damage
        q+=mini(c.block,maxi(0,incoming-h.block))*1.1/maxf(1,c.cost)
      if q>score:best=i;target=t;score=q
    if best>=0 and score>0:g.play_card(best,target)
    else:g.end_turn()
 if steps>=2000:failures+=1;printerr("FAIL: simulation stuck")
