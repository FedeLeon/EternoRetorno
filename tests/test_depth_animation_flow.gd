extends SceneTree
const Game=preload("res://src/game.gd")
var app: Control
var failures=0;var checks=0
func check(ok: bool,message: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",message)
func _initialize():call_deferred("run_tests")
func run_tests():
	root.size=Vector2i(1280,720)
	app=load("res://main.tscn").instantiate();app.game=Game.new("user://unused-depth-flow",false);root.add_child(app)
	app.game.new_run(["warrior","guardian"],202);app.game.enter_node(0)
	var enemy=app.game.run.combat.enemies[0];enemy.hp=300;enemy.max_hp=300;enemy.intent={"damage":0,"block":0,"target":0,"counter":0}
	app.game.run.combat.hand=[{"id":"warrior_prepared","upgraded":false}];app.continue_run();await process_frame
	var hp=enemy.hp
	app.animate_combat_action(0,0)
	while app.combat_busy:await process_frame
	check(enemy.hp==hp and app.game.run.combat.prepared.size()==1,"preparation has no premature strike")
	app.animate_combat_action()
	while app.combat_busy:await process_frame
	check(enemy.hp==hp-17 and not app.game.resolved_prepared_hits.is_empty(),"prepared strike replays after enemy actions")
	check(app.hero_art[0].get_meta("detailed",false) and app.hero_art[1].get_meta("detailed",false),"battle uses detailed heroes")
	var guard=app.game.content.cards.keys().filter(func(id):return app.game.content.cards[id].owner=="warrior" and app.game.content.cards[id].block>0 and app.game.content.cards[id].target=="self")[0]
	app.game.run.combat.hand=[{"id":guard,"upgraded":false}];app.game.run.combat.energy=3;app.render();await process_frame
	app.animate_combat_action(0,0)
	while app.combat_busy:await process_frame
	check(app.hero_art[0].current_action=="idle","drawn guard returns to idle")
	app.queue_free();await process_frame;await process_frame
	print("DEPTH FLOW: %d checks / %d failures"%[checks,failures]);quit(1 if failures else 0)
