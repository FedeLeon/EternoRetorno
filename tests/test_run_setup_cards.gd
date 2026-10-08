extends SceneTree
const Setup = preload("res://src/ui/screens/run_setup_screen.gd")
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",message)
func _initialize() -> void: call_deferred("verify")
func click(button: Button) -> void:
	var position = button.get_global_rect().get_center()
	var motion = InputEventMouseMotion.new(); motion.position = position; root.push_input(motion)
	var event = InputEventMouseButton.new(); event.button_index = MOUSE_BUTTON_LEFT; event.position = position; event.pressed = true; root.push_input(event)
	var released = event.duplicate(); released.pressed = false; root.push_input(released)
func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("run-setup/"+name+".png"))
func verify() -> void:
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://unused-setup-cards",false)
	root.add_child(app)
	app.game.profile.difficulty_unlocked = 1
	app.game.profile.preferred_difficulty = 0
	app.game.profile.preferred_variant = "normal"
	var profile = app.game.profile.duplicate(true)
	Setup.open(app,3,func(floor): app.game.new_run(["warrior","cleric"],72,{},floor))
	await process_frame
	check(app.overlay.find_children("*","OptionButton",true,false).is_empty(),"no dropdowns")
	check(app.overlay.find_children("DifficultyCard*","Button",true,false).size()==4 and app.overlay.find_children("ConditionCard*","Button",true,false).size()==3,"four difficulty and three condition cards")
	check(app.overlay.get_node("DifficultyCard2").disabled and app.overlay.get_node("DifficultyCard3").disabled,"locked tiers cannot be selected")
	await capture("locked")
	click(app.overlay.get_node("DifficultyCard1")); await process_frame
	click(app.overlay.get_node("ConditionCard_tainted")); await process_frame
	check(app.overlay.get_node("DifficultyCard1").button_pressed and not app.overlay.get_node("DifficultyCard0").button_pressed,"exclusive difficulty selection by click")
	check(app.overlay.get_node("ConditionCard_tainted").button_pressed and not app.overlay.get_node("ConditionCard_normal").button_pressed,"exclusive condition selection by click")
	check(app.game.profile==profile,"draft does not change preferences")
	click(app.overlay.get_node("CancelRunSetup")); await process_frame
	check(app.game.profile==profile,"cancel preserves preferences")
	app.game.profile.difficulty_unlocked = 3
	Setup.open(app,3,func(floor): app.game.new_run(["warrior","cleric"],72,{},floor))
	await process_frame
	click(app.overlay.get_node("DifficultyCard3")); await process_frame
	click(app.overlay.get_node("ConditionCard_dangerous")); await process_frame
	await capture("selected")
	for button in app.overlay.find_children("*Card*","Button",true,false):
		check(button.get_global_rect().end.x<=1280 and button.get_global_rect().end.y<=720,"cards fit screen")
		check(button.get_children().filter(func(n):return n is TextureRect and n.texture != null).size()==1,"illustration present")
	click(app.overlay.get_node("StartAdventure")); await process_frame
	check(app.game.run.floor==3 and app.game.run.difficulty==3 and app.game.run.variant=="dangerous","start applies clicked configuration")
	app.close_modal(); app.queue_free(); await process_frame
	print("RUN SETUP CARDS: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
