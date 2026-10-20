extends SceneTree
var checks=0
var failures=0
func _initialize() -> void:call_deferred("verify")
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",message)
func press_back(app: Control) -> void:
	var arrow=app.layer.get_node_or_null("HeaderBack")
	check(arrow is Button and arrow.icon!=null,"shared arrow is visible")
	if arrow==null:return
	check(arrow.position==Vector2(24,20),"consistent top-left position")
	check(arrow.size==Vector2(44,44) and arrow.scale==Vector2.ONE,"fixed square after minimum-size layout")
	check(arrow.icon_alignment==HORIZONTAL_ALIGNMENT_CENTER and arrow.get_theme_constant("icon_max_width")==24,"same centered arrow in every view")
	for state in ["normal","hover","pressed","disabled"]:
		var style=arrow.get_theme_stylebox(state)
		check(style is StyleBoxTexture and style.texture.resource_path=="res://assets/ui/polished/button.svg","shared frame in "+state)
		check(style.get_content_margin(SIDE_LEFT)==8 and style.get_content_margin(SIDE_TOP)==8 and style.get_content_margin(SIDE_RIGHT)==8 and style.get_content_margin(SIDE_BOTTOM)==8,"symmetric padding in "+state)
	arrow.pressed.emit();await process_frame
func verify() -> void:
	root.size=Vector2i(1280,720)
	var app=load("res://main.tscn").instantiate()
	app.game=preload("res://src/game.gd").new("user://unused-header-back",false)
	app.game.profile.tutorial_complete=true
	root.add_child(app)
	check(not app.layer.has_node("HeaderBack"),"home has no previous view")
	app.open_base_camp();await process_frame
	await shot(app,"camp")
	await press_back(app);check(app.screen=="home","camp returns home")
	for building in ["market","forge","church"]:
		app.open_base_camp();app.screen=building;app.render();await process_frame
		app.set(building+"_hero","warrior");app.render();await process_frame
		await shot(app,building)
		var before=app.game.profile.duplicate(true)
		check(not app.layer.has_node("BackToHeroes"),"redundant category button removed: "+building)
		await press_back(app)
		check(app.screen==building and app.get(building+"_hero")=="","detail returns to hero selection: "+building)
		await press_back(app);check(app.screen=="base_camp","gallery returns camp: "+building)
		check(app.game.profile==before,"back does not buy, build or save: "+building)
	for screen in ["expeditions","training_setup","select","refuge"]:
		app.screen=screen;app.render();await process_frame
		await press_back(app);check(app.screen=="base_camp","return from "+screen)
	app.screen="select";app.render();app.screen="equipment";app.render();await process_frame
	check(not app.layer.has_node("BackToCharacters"),"component footer back removed")
	await press_back(app);check(app.screen=="select","components return to selected party")
	app.open_base_camp();app.screen="options";app.render();app.set_option("volume",.5);await process_frame
	await shot(app,"options")
	await press_back(app);check(app.screen=="base_camp","options retain actual origin across rerenders")
	app.screen="home";app.render();app.open_collection();await process_frame
	await shot(app,"collection")
	await press_back(app);check(app.screen=="home","collection returns home")
	app.screen="cinematics";app.render();app.screen="options";app.render();await process_frame
	await press_back(app);check(app.screen=="cinematics","nested auxiliary returns to its actual parent")
	await press_back(app);check(app.screen=="home","cinematics preserve their own origin after nested return")
	app.game.new_run(["warrior","guardian"],33);app.game.enter_node(0);app.continue_run();await process_frame
	check(not app.layer.has_node("HeaderBack"),"combat cannot rewind an encounter")
	var committed=app.game.run.duplicate(true)
	app.open_deck();await process_frame
	await press_back(app);check(app.screen=="combat" and app.game.run==committed,"deck returns to current battle without changing it")
	app.selected_card=0;app.back();check(app.screen=="combat" and app.selected_card==-1,"Escape still cancels card selection")
	app.combat_busy=true;app.back();check(app.screen=="combat","busy combat cannot navigate away");app.combat_busy=false
	for screen in ["reward","boss_reward","room","paths","event_cards","victory","defeat"]:
		app.screen=screen
		check(not app.navigation.can_return(app),"no rewind from resolved/mandatory phase: "+screen)
	app.queue_free();await process_frame;await process_frame
	print("HEADER BACK: %d checks / %d failures"%[checks,failures])
	quit(1 if failures else 0)

func shot(app: Control, id: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("header_back/"+id+".png"))
