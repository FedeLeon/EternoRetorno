extends SceneTree
var checks = 0
var failures = 0
const Game = preload("res://src/game.gd")
func _initialize(): call_deferred("run_tests")
func check(ok: bool, label: String):
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",label)
func run_tests():
	var game = Game.new("user://unused-expansion.save",false)
	check(game.new_run(["warrior","cleric"],27,{},3),"floor 3 selectable")
	check(game.run.floor_count == 3 and game.run.nodes.size() == 28,"third floor inventory")
	for floor in range(1,4):
		for seed_value in range(20):
			game.new_run(["warrior","cleric"],seed_value,{},floor)
			for node in game.run.nodes:
				check(game.content.events.has(node.event),"encounter defined")
				for enemy in node.encounter: check(game.content.enemies.has(enemy),"enemy defined")
				check(node.encounter.size() <= 3,"group bound")
	game.new_run(["warrior","cleric"],17)
	game.enter_node(0)
	var card_id = game.run.deck[0].id
	game.run.combat.hand = [{"id":card_id,"upgraded":false}]
	game.run.combat.energy = 10
	var snapshot = game.run.duplicate(true)
	var profile = game.profile.duplicate(true)
	var rng_state = game.rng.state
	var preview = preload("res://src/rules/combat_preview.gd").describe(game,0,0)
	check(not preview.is_empty(),"combat preview")
	check(game.run == snapshot and game.profile == profile and game.rng.state == rng_state,"preview leaves save/RNG untouched")
	game.run.phase = "reward"; game.run.reward = [{"id":card_id,"upgraded":false}]
	var souls = game.profile.souls; var cards = game.run.deck.size()
	check(game.choose_reward(-1) and game.profile.souls == souls+12 and game.run.deck.size()==cards,"skip awards souls without card")
	check(not game.choose_reward(-1) and game.profile.souls == souls+12,"skip cannot pay twice")
	game.run.phase="room"; game.run.nodes[game.run.current].kind="event";game.run.nodes[game.run.current].event="forest_hunter"
	check(game.choose_event(0) and game.run.phase=="event_cards","event opens deck choice")
	check(game.modify_event_card(0) and game.run.deck.size()==cards-1,"remove exact selected card")
	game.run.phase="room";game.run.nodes[game.run.current].event="forge_altar"
	game.choose_event(0);game.modify_event_card(0)
	check(game.run.deck[0].upgraded,"transformation yields upgraded replacement")
	game.run.phase="map";game.run.boss_defeated=true;game.run.floor=1;game.run.floor_count=2
	check(game.descend() and game.run.floor==2 and game.run.floor_count==2,"legacy run retains two floors")
	game.run.boss_defeated=true;game.descend()
	check(game.run.phase=="victory" and game.profile.bonds.size()==1,"settlement grants bond")
	var victories = game.profile.victories;game._finish(true)
	check(game.profile.victories==victories,"idempotent finish")
	check(game.configure_bond(["warrior","cleric"],"protective"),"select unlocked link variant")
	game.profile.preferred_difficulty=3;game.new_run(["warrior","cleric"],1)
	check(game.run.difficulty==1,"locked difficulties cannot be selected")
	game.run.phase="map";game.run.boss_defeated=true;game.descend();game.run.boss_defeated=true;game.descend()
	check(game.run.floor==3 and game.run.phase=="map","second guardian leads to fortress")
	game.run.boss_defeated=true;game.descend()
	check(game.run.phase=="victory" and game.profile.difficulty_unlocked==2,"full adventure unlocks next difficulty")
	game.new_run(["warrior","cleric"],17,{},3)
	game.enter_node(0); game._start_combat(["volcano_boss"])
	var boss: Dictionary = game.run.combat.enemies[0]
	boss.hp = int(boss.max_hp / 2)
	game._check_combat_end()
	check(boss.enraged and boss.intent.get("all", false) and boss.intent.block == 6,"boss crosses visible second phase")
	game._start_combat(["ice_elemental","crypt_lancer_new"])
	for enemy in game.run.combat.enemies: enemy.intent={"damage":0,"target":0,"block":0}
	game.end_turn()
	check(game.run.combat.enemies[1].block == 3,"protector guard survives ally action")
	game._start_combat(["watch_owl","forest_cutthroat"])
	game.run.combat.enemies[1].hp -= 10
	for enemy in game.run.combat.enemies: enemy.intent={"damage":0,"target":0,"block":0}
	game.end_turn()
	check(game.run.combat.enemies[1].hp == game.run.combat.enemies[1].max_hp - 7,"support heals surviving ally")
	game.profile.preferred_difficulty=2;game.profile.difficulty_unlocked=2;game.profile.preferred_variant="dangerous"
	game.new_run(["warrior","cleric"],17,{},3);game.enter_node(0)
	check(game.run.nodes.filter(func(n): return n.kind == "elite").size() >= 3,"dangerous condition adds elite")
	var enemy: Dictionary = game.run.combat.enemies[0]
	check(enemy.max_hp == ceili(game.content.enemies[enemy.id].hp * 1.12),"difficulty scales HP")
	check(preload("res://src/rules/adventure_extensions.gd").intent(enemy,game.content.enemies[enemy.id],3,[enemy]).get("counter",0)==4,"higher difficulty counter cadence")
	var save_path = "user://adventure-compatibility-test.save"
	var saved = Game.new(save_path,true)
	saved.new_run(["ranger","rogue"],77)
	saved.run.floor_count=2;saved.checkpoint()
	var loaded = Game.new(save_path,true)
	check(loaded.run == saved.run and loaded.rng.state == saved.rng.state,"old two-floor snapshot reloads unchanged")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(save_path+suffix)
	print("ADVENTURE EXPANSION: %d checks / %d failures" %[checks,failures]);quit(1 if failures else 0)
