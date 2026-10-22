extends SceneTree
const Game = preload("res://src/game.gd")
var checks=0
var failures=0
var app: Control
func _initialize() -> void: call_deferred("verify")
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",message)
func capture(id: String) -> void:
	if DisplayServer.get_name()=="headless":return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("static_combat/"+id+".png"))
func settle() -> void:
	var deadline=Time.get_ticks_msec()+15000
	while app.combat_busy and Time.get_ticks_msec()<deadline:await process_frame
	check(not app.combat_busy,"presentation completes without waiting for sprite frames")
func verify() -> void:
	root.size=Vector2i(1280,720)
	app=load("res://main.tscn").instantiate();app.game=Game.new("user://static-combat.save",true)
	app.game.profile.tutorial_complete=true;root.add_child(app)
	for party in [["warrior","guardian"],["rogue","mage"]]:
		for floor_number in [1,2,3]:
			app.game.new_run(party,42,{},floor_number);app.game.enter_node(0)
			app.game._start_combat(["skeleton","skeleton_shielder"])
			for enemy in app.game.run.combat.enemies:enemy.hp=1000;enemy.max_hp=1000;enemy.block=0
			for hero in app.game.run.heroes:hero.block=1000
			var card=app.game.content.cards.keys().filter(func(id):
				var c=app.game.content.cards[id]
				return c.owner==party[0] and c.damage>0 and c.cost<=1 and not c.get("charge",false))[0]
			app.game.run.combat.hand=[{"id":card,"upgraded":false}];app.game.run.combat.energy=9
			app.continue_run();await process_frame
			var origin=app.hero_art[0].position
			app.animate_combat_action(0,int(app.game.valid_targets(0)[0]))
			var committed=app.game.run.duplicate(true)
			check(Game.new("user://static-combat.save",true).run==committed,"save resolves before visual presentation")
			var deadline=Time.get_ticks_msec()+5000
			while app.combat_busy and app.hero_art[0].current_action!="attack" and Time.get_ticks_msec()<deadline:await process_frame
			check(app.hero_art[0].current_action=="attack","attack selects its authored sequence")
			var transform=app.hero_art[0].sprite.get_transform()
			await create_timer(.08).timeout
			check(app.hero_art[0].sprite.get_transform()==transform and app.hero_art[0].position==origin,"authored poses keep body transform fixed while cut-in plays")
			await capture("floor%d-%s-attack"%[floor_number,party[0]])
			await settle()
			check(app.game.run==committed,"presentation never reapplies damage or changes saved state")
			check(app.hero_art[0].current_action=="idle","completed attack restores combat idle")
			# Defense-only enemies exercise the fixed guard pose and foreground effect.
			for enemy in app.game.run.combat.enemies:enemy.intent={"damage":0,"block":7,"target":0}
			app.animate_combat_action();await settle()
			check(app.hero_art.values().all(func(actor):return not actor.is_processing()),"actors keep animation processing in their player")
	app.queue_free();await process_frame
	print("STATIC COMBAT FLOW: %d checks / %d failures"%[checks,failures]);quit(1 if failures else 0)
