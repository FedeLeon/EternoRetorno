extends SceneTree
const Game=preload("res://src/game.gd")
const Feedback=preload("res://src/presentation/impact_feedback.gd")
var checks=0
var failures=0
func _initialize() -> void:call_deferred("verify")
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",message)
func verify() -> void:
	root.size=Vector2i(1280,720)
	var app=load("res://main.tscn").instantiate()
	app.game=Game.new("user://unused-damage-position",false)
	app.game.profile.tutorial_complete=true
	root.add_child(app)
	var prefs=preload("res://src/presentation/preferences.gd")
	var old_strength=prefs.settings.get("impact_strength",.65)
	prefs.settings.impact_strength=0.0
	for floor_number in [1,2,3]:
		app.game.new_run(["warrior","guardian"] if floor_number==1 else ["rogue","mage"],32,{},floor_number)
		app.game.enter_node(0)
		app.game._start_combat(["skeleton","skeleton_shielder","skeleton_mage"] if floor_number!=2 else ["boss"])
		app.continue_run();await process_frame
		var before=app.game.run.duplicate(true)
		var labels: Array=[]
		for actor in app.hero_art.values()+app.enemy_art.values():
			Feedback.play(app,actor,{"damage":7,"lost":7})
			var label=app.layer.get_child(app.layer.get_child_count()-1)
			labels.append(label)
			check(label is Label and label.text=="-7","damage label created")
			var bounds: Rect2=label.get_global_rect()
			var sprite_bounds: Rect2=actor.get_global_transform()*actor.body_rect()
			check(bounds.position.y>=164 and bounds.end.y<414,"number begins in battlefield, below menu and above cards")
			check(bounds.intersects(sprite_bounds.grow(32)),"number sits next to visible character rather than its container")
			check(bounds.position.x>=0 and bounds.end.x<=1280,"number stays on screen")
		if DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("damage_position/floor%d.png"%floor_number))
		await create_timer(.65).timeout
		for label in labels:
			check(is_instance_valid(label) and label.global_position.y>=126,"floating motion never reaches top HUD")
		check(app.game.run==before,"damage presentation preserves game state")

	prefs.settings.impact_strength=old_strength
	app.queue_free();await process_frame;await process_frame
	print("DAMAGE NUMBER POSITION: %d checks / %d failures"%[checks,failures])
	quit(1 if failures else 0)
