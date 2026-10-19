extends SceneTree
const Game = preload("res://src/game.gd")
var failures = 0
var checks = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func _initialize() -> void:
	call_deferred("run_tests")
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-pet-ui", false)
	root.add_child(app)
	app.open_selection()
	await process_frame
	check(app.selected_pet == "dog", "new preparation defaults to visible dog selection")
	for id in ["dog", "cat"]:
		var card = app.layer.get_node("Pet_" + id)
		check(card.size == Vector2(355,140), "pet card has reserved space")
		check(card.get_global_rect().end.y < 342, "pets do not overlap seated hero targets")
		check(preload("res://src/ui/components/pet_choice.gd").texture(id).get_size() == Vector2(192,192), "pet portrait uses one camp pose")
	app.layer.get_node("Pet_cat").pressed.emit()
	await process_frame
	check(app.selected_pet == "cat", "cat selectable")
	app.toggle_hero("warrior")
	app.toggle_hero("guardian")
	app.open_equipment()
	await process_frame
	check(app.selected_pet == "cat", "component selection keeps pet")
	check(app.layer.get_node("PetSummary").text.contains("Curiosidad"), "loadout confirms companion passive")
	app.back()
	await process_frame
	check(app.selected_pet == "cat" and app.selected_party.size() == 2, "return keeps pet and heroes")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("pets/selection.png"))
	app.game.new_run(app.selected_party, 42, {}, 1, app.selected_pet)
	app.game.enter_node(0)
	app.continue_run()
	await process_frame
	check(app.equipped_relics()[0].name == "Gato · Curiosidad", "battle exposes pet explanation")
	var hud = app.layer.get_node("CombatHUD")
	hud.get_node("Relic0").pressed.emit()
	check(hud.has_node("RelicPopover") and hud.open_relic == 0, "pet icon opens explanation")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("pets/combat.png"))
	app.queue_free()
	await process_frame
	print("Pets UI: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
