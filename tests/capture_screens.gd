extends SceneTree
var app: Control
func _initialize() -> void:
	call_deferred("capture")
func shot(name: String) -> void:
	await process_frame
	await process_frame
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/" + name + ".png")
func capture() -> void:
	app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://capture-unused.save", false)
	root.add_child(app)
	await shot("01-inicio")
	app.open_selection(); app.toggle_hero("warrior"); app.toggle_hero("mage")
	await shot("02-personajes")
	app.game.new_run(["warrior", "mage"], 42); app.continue_run()
	await shot("03-mapa")
	app.game.enter_node(0); app.continue_run()
	await shot("04-combate")
	app.selected_card = 0; app.render()
	await shot("05-objetivos")
	app.game._make_reward(); app.continue_run()
	await shot("06-recompensa")
	app.game.choose_reward(-1); app.game.run.current = 5; app.game.enter_node(6); app.continue_run()
	await shot("07-descanso")
	app.open_deck()
	await shot("08-mazo")
	app.open_collection()
	await shot("09-coleccion")
	app.game._finish(true); app.continue_run()
	await shot("10-victoria")
	quit()
