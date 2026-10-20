extends SceneTree
const Game = preload("res://src/game.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func shot(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("retired_projects_pets/"+id+".png"))
func verify() -> void:
	for old_pet in ["dog", "cat"]:
		var path = "user://retired-systems-"+old_pet+".save"
		var original = Game.new(path, false)
		original.new_run(["warrior","guardian"],42)
		original.enter_node(0)
		original.profile.projects = {"reservation":true,"refresh":true,"scouting":true}
		original.profile.reserved_card = "warrior_risk"
		original.run.pet = old_pet
		original.run.merchant_refresh_floor = 1
		original.run.nodes[0].scouted = true
		var expected_profile = original.profile.duplicate(true)
		expected_profile.erase("projects"); expected_profile.erase("reserved_card")
		var expected_run = original.run.duplicate(true)
		expected_run.erase("pet"); expected_run.erase("merchant_refresh_floor")
		expected_run.nodes[0].erase("scouted")
		check(original.store.write(original.profile, original.run), "write historical save fixture")
		var loaded = Game.new(path,true)
		check(loaded.profile == expected_profile, "retired flags removed without changing currency or progress")
		check(loaded.run == expected_run, "ongoing battle, hand, HP and RNG preserved")
		var reloaded = Game.new(path,true)
		check(reloaded.profile == loaded.profile and reloaded.run == loaded.run, "cleanup persisted and idempotent")
		loaded._start_combat(["rat"])
		check(loaded.run.combat.hand.size() == 6, "new battle has no extra pet draw")
		check(loaded.run.heroes.all(func(h): return h.block == 0), "new battle has no pet block")
		for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path+suffix)
	var game = Game.new("user://unused-retired-actions",false)
	game.new_run(["warrior","guardian"],42)
	var before = game.profile.duplicate(true)
	var state = game.rng.state
	for action in ["project","reserve","refresh","scout"]:
		check(not game.polish_action(action,{"id":"reservation"}), "retired transaction rejected: "+action)
	check(game.profile == before and game.rng.state == state, "retired actions cannot charge or consume RNG")
	game.profile.buildings.market = true
	var price = int(game.content.cards.warrior_risk.market_price)
	var balance = game.profile.souls
	check(game.buy_market_card("warrior_risk") and game.profile.souls == balance-price, "market uses full catalogue price")
	root.size = Vector2i(1280,720)
	var app = load("res://main.tscn").instantiate()
	app.game = game
	root.add_child(app)
	app.open_base_camp()
	await process_frame
	check(not app.layer.has_node("ProjectsBuilding") and not app.layer.has_node("ProjectsEntrance"), "camp has no projects")
	check(app.layer.has_node("CampDog") and app.layer.has_node("CampCat"), "ambient animals retained")
	check(app.layer.get_node("CampDog").is_processing() and app.layer.get_node("CampCat").is_processing(), "ambient animations still running")
	await shot("camp")
	app.open_selection()
	await process_frame
	check(not app.layer.find_children("Pet*","",true,false).size(), "preparation has no pet selector")
	app.toggle_hero("warrior"); app.toggle_hero("guardian")
	await shot("selection")
	app.open_equipment()
	await process_frame
	check(not app.layer.has_node("PetSummary"), "components have no pet summary")
	await shot("equipment")
	app.game.enter_node(0)
	app.continue_run()
	await process_frame
	check(not app.game.run.has("pet") and app.equipped_relics().is_empty(), "new adventure and HUD have no pet passive")
	await shot("combat")
	app.queue_free()
	await process_frame
	await process_frame
	print("RETIRED PROJECTS/PETS: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
