extends SceneTree
const Game=preload("res://src/game.gd")
var app: Control
var checks=0;var failures=0
func _initialize():call_deferred("run_tests")
func check(ok: bool,caption: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",caption)
func capture(name: String):
	if DisplayServer.get_name()=="headless":return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat-depth/"+name+".png"))
func run_tests():
	root.size=Vector2i(1280,720)
	app=load("res://main.tscn").instantiate();app.game=Game.new("user://unused-depth-ui",false)
	root.add_child(app);await process_frame
	app.game.new_run(["warrior","guardian"],82);app.game.enter_node(0)
	var original=app.game;var original_run=original.run.duplicate(true);var profile=original.profile.duplicate(true)
	app.screen="training_setup";app.render();await process_frame;await capture("training-setup")
	preload("res://src/ui/training_navigation.gd").start(app,["mage","rogue"],2,3);await process_frame
	check(app.game!=original and not app.game.save_enabled,"training isolates persistent game")
	check(app.game.run.combat.energy==99 and app.game.run.heroes[0].forge.weapon==2,"training gear and energy")
	await capture("training-combat")
	preload("res://src/ui/training_navigation.gd").cards(app);await process_frame
	check(app.overlay.get_parent()==app,"training picker overlay attached to root")
	await capture("training-cards");app.close_modal()
	preload("res://src/ui/training_navigation.gd").leave(app);await process_frame
	check(app.game==original and original.run==original_run and original.profile==profile,"leaving restores exact original game/profile")
	app.screen="bestiary";app.render();await process_frame;await capture("bestiary")
	check(app.game.profile.bestiary.size()>0,"bestiary populated")
	app.game.run.phase="merchant";preload("res://src/rules/travel_encounters.gd").prepare(app.game)
	app.continue_run();await process_frame;await capture("merchant")
	app.game.merchant_action("leave")
	app.game.run.phase="room";app.game.run.nodes[app.game.run.current].kind="rest"
	app.screen="deck";app.return_screen="room";app.upgrade_mode=true;app.render();await process_frame
	var upgrade=app.layer.get_node("CardUpgradeScreen");upgrade.select(0);upgrade.choose_branch(1)
	check(upgrade.variant=="efficient" and not upgrade.confirm.disabled,"upgrade branch preview choice")
	await capture("upgrade-choice")
	app.game._finish(false);app.open_collection();await process_frame
	var gallery=app.layer.get_node("CollectionScreen");gallery.show_tab(2);await process_frame
	gallery.history_detail(gallery.snapshot.history[0]);await process_frame;await capture("history-detail");app.close_modal()
	preload("res://src/ui/components/reading_dialog.gd").open(app,"Registro", "Daño y bloqueo\n".repeat(30));await process_frame
	check(app.overlay.z_index==200,"scrolling log above cards")
	await capture("combat-log");app.close_modal()
	app.queue_free();await process_frame;await process_frame
	print("COMBAT DEPTH UI: %d checks / %d failures"%[checks,failures]);quit(1 if failures else 0)
