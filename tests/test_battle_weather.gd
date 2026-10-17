extends SceneTree
const Game = preload("res://src/game.gd")
const Weather = preload("res://src/presentation/battle_atmosphere.gd")
const Preferences = preload("res://src/presentation/preferences.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",message)
func verify() -> void:
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-weather",false); root.add_child(app)
	for floor_number in [1,2,3]:
		app.game.new_run(["rogue","mage"],82,{},floor_number)
		app.game.enter_node(0)
		var saved = app.game.run.duplicate(true); var rng = app.game.rng.state
		app.screen = "combat"; app.render(); await process_frame
		var weather = app.layer.get_node("BattleAtmosphere")
		weather.set_process(false)
		check(weather.get_index() < app.hero_art[0].get_parent().get_index(), "weather stays behind fighters")
		check(weather.mouse_filter == Control.MOUSE_FILTER_IGNORE, "weather never blocks card targets")
		for variant in range(3):
			weather.weather_variant = variant
			check(weather.rainy() == (floor_number>1 and variant==2), "outdoor rain only in occasional exterior variant")
			weather.elapsed = 1.0
			var before = weather.particle_position(0)
			weather._process(0.05)
			check(weather.particle_position(0) != before, "weather moves over time")
			for index in range(weather.particle_count()):
				var point = weather.particle_position(index)
				check(point.x>=0 and point.x<1280 and point.y>=80 and point.y<=410, "particles stay in arena above cards")
			if DisplayServer.get_name() != "headless":
				weather.queue_redraw(); await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("guard_weather/floor%d-weather%d.png" % [floor_number,variant]))
		Preferences.settings.low_effects = true
		check(weather.particle_count()==8,"reduced effects retain bounded light atmosphere")
		weather._process(0.1)
		check(weather.elapsed>1,"low effects still animates weather")
		Preferences.settings.low_effects = false
		check(app.game.run==saved and app.game.rng.state==rng,"weather cannot mutate combat/save/RNG")
	app.queue_free(); await process_frame
	print("BATTLE WEATHER: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
