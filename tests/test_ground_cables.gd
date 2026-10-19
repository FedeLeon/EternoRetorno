extends SceneTree
const Game = preload("res://src/game.gd")
const Layout = preload("res://src/ui/components/combat_layout.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",message)
func verify() -> void:
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-ground-cables",false); root.add_child(app)
	app.game.new_run(["warrior","guardian"],82,{},3); app.game.enter_node(0)
	app.game._start_combat(["boss"])
	var unit = app.game.run.combat.enemies[0]
	unit.root_hp = 10
	var before = app.game.run.duplicate(true); var rng = app.game.rng.state
	app.screen = "combat"; app.render(); await process_frame
	var actor = app.enemy_art[0]
	var target = actor.get_parent()
	var cables = target.get_node("GroundCables")
	check(cables.get_index()<actor.get_index(),"cables render behind enemy artwork")
	check(cables.global_position.y>=Layout.ground_for(app)-1,"cables lie on ground, not over body")
	check(cables.get_global_rect().end.y<=app.enemy_health[0].global_position.y,"cables do not cover life below feet")
	check(cables.size.y==8 and cables.size.x>cables.size.y*20,"restraints are horizontal rather than circular")
	check(cables.mouse_filter==Control.MOUSE_FILTER_IGNORE,"cables never consume enemy clicks")
	check(not cables is TextureRect,"old circular artwork is not displayed")
	cables.set_process(false)
	cables._process(0.2)
	check(cables.elapsed>0,"electrical effect advances")
	check(app.game.run==before and app.game.rng.state==rng,"animation leaves rules/save/RNG unchanged")
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("ground_cables/boss.png"))
	app.enemy_health[0].animate_to(0)
	if app.enemy_health[0].animating: await app.enemy_health[0].animation_finished
	check(not cables.visible,"cables disappear when displayed enemy dies")
	unit.root_hp=0;app.render();await process_frame
	check(app.enemy_art[0].get_parent().get_node_or_null("GroundCables")==null,"no cables after restraint expires")
	unit.hp=0;unit.root_hp=10;app.render();await process_frame
	check(app.enemy_art[0].get_parent().get_node_or_null("GroundCables")==null,"fallen enemy has no cables")
	app.queue_free(); await process_frame
	print("GROUND CABLES: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
