extends SceneTree
const Game = preload("res://src/game.gd")
const Room = preload("res://tests/room_fixture.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, caption: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", caption)
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-boss-navigation",false)
	root.add_child(app)
	await process_frame
	for floor_number in [1,2,3]:
		app.game.new_run(["warrior","guardian"],42,{},floor_number)
		app.game.profile.settings = {"auto_cinematics":false}
		Room.enter(app.game,"boss")
		Room.break_objective(app.game)
		for enemy in app.game.run.combat.enemies: enemy.hp = 0
		app.game._check_combat_end()
		app.game.choose_reward(-1)
		app.continue_run()
		await process_frame
		check(app.screen == "boss_reward","exclusive relic choice before transition")
		var id: String = app.game.run.boss_offers[0]
		var button = app.layer.find_child("BossRelic_"+id,true,false)
		for pressed in [true,false]:
			var event = InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = pressed
			event.position = button.get_global_rect().get_center()
			root.push_input(event)
		await process_frame
		check(app.screen == "paths" and id in app.game.run.relics,"real choice opens next paths and grants relic")
		check(app.game.run.floor == mini(3,floor_number+1),"map belongs to next floor")
		var next_map = app.layer.find_child("DungeonMap",true,false)
		if next_map == null:
			next_map = app.layer.get_children().filter(func(n): return n.get_script() == preload("res://src/ui/screens/paths_screen.gd"))[0]
		if floor_number<3:
			check(not next_map.has_node("Descend") and app.game.available_nodes()==[0,1,2],"single entrance path without extra transition button")
			check(next_map.dungeon_name == preload("res://src/dungeon.gd").definition(floor_number+1).name,"next dungeon title rendered")
		else:
			check(next_map.has_node("Descend") and app.game.profile.victories==0,"last floor retains adventure completion")
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("boss-navigation/after-floor-%d.png" % floor_number))
	app.queue_free()
	await process_frame
	await create_timer(.3).timeout
	print("BOSS RELIC NAVIGATION: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
