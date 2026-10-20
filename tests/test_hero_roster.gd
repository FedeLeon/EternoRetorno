extends SceneTree
const Game = preload("res://src/game.gd")
const Roster = preload("res://src/rules/hero_roster.gd")
const Contracts = preload("res://src/rules/expeditions.gd")
var checks = 0
var failures = 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures += 1;printerr("FAIL: ",label)
func _initialize() -> void: call_deferred("run_tests")
func run_tests() -> void:
	var game = Game.new("user://unused-roster.save",false)
	check(Roster.ids(game.content.heroes) == Roster.ACTIVE,"four active heroes in stable order")
	check(game.content.heroes.size()==4,"only four hero definitions remain")
	var filtered = Roster.heroes(game.content.heroes)
	filtered.warrior.hp=1
	check(game.content.heroes.warrior.hp>1,"filtered gallery does not mutate definitions")
	var seen = {}
	for i in range(100):
		Contracts.refresh(game.profile)
		check(game.profile.expeditions.offers.size()==3,"three offers per cycle")
		for id in game.profile.expeditions.offers:
			var party: Array = Contracts.definition(id).party
			check(Roster.supports(party),"fresh contracts avoid retired heroes")
			if party.size()==2: seen[id]=true
	check(seen.size()==6,"all six active pair contracts can appear")
	var legacy = "unknown_pair"
	game.profile.expeditions.offers=[legacy,"pair_warrior_guardian","pair_rogue_mage"]
	game.profile.expeditions.selected="pair_warrior_guardian"
	check(Contracts.migrate(game.profile),"stale camp offers migrate")
	check(game.profile.expeditions.selected=="pair_warrior_guardian" and game.profile.expeditions.offers.count("pair_warrior_guardian")==1,"active selection survives without duplicate offer")
	game.profile.expeditions.offers=[legacy,"pair_warrior_guardian","pair_rogue_mage"]
	game.profile.expeditions.selected=legacy
	check(Contracts.migrate(game.profile,{"phase":"combat"}),"unknown contracts are removed even during an adventure")
	game.profile.expeditions.selected = "unknown_pair"
	check(Contracts.migrate(game.profile) and game.profile.expeditions.selected.is_empty(), "unknown selection is cleared even with valid offers")
	var path = "user://roster-legacy-%d.save" % OS.get_process_id()
	var old = Game.new(path,true)
	old.profile.expeditions.offers=[legacy,"pair_warrior_guardian","pair_rogue_mage"]
	old.profile.expeditions.selected=legacy
	check(old.new_run(["warrior","guardian"],113),"valid pair starts")
	old.enter_node(0)
	var snapshot = old.run.duplicate(true)
	var restored = Game.new(path,true)
	check(restored.run==snapshot,"valid adventure and RNG preserved")
	old.profile.souls = 1234
	old.profile.forge_upgrades.unknown_hero = {"weapon":3,"armor":2}
	old.run.party = ["unknown_hero","guardian"]
	old.checkpoint()
	restored = Game.new(path,true)
	check(restored.run.is_empty(),"unsupported adventure closes safely")
	check(restored.profile.souls==1234 and not restored.profile.forge_upgrades.has("unknown_hero"),"valid progress survives obsolete content cleanup")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path+suffix)
	var app = load("res://main.tscn").instantiate()
	app.game=game
	root.size=Vector2i(1280,720)
	root.add_child(app);await process_frame
	app.open_selection();await process_frame
	check(app.layer.find_children("CampHero_*","Button",true,false).size()==4,"four selection slots")

	for screen in ["market","forge","church","refuge","training_setup"]:
		app.screen=screen;app.render();await process_frame
		var portraits=app.layer.find_children("RefugeHero_*","Button",true,false)
		if screen in ["market","forge","church","training_setup"]:
			portraits=app.layer.find_children({"market":"Category_*","forge":"ForgeHero_*","church":"ChurchHero_*","training_setup":"TrainingHero_*"}[screen],"Button",true,false)
		check(portraits.size()==4,"four gallery entries: "+screen)
		for portrait in portraits:
			var picture=portrait.get_node("ComicPortrait")
			var expected = "res://assets/heroes/identity/portraits/%s.png" % portrait.name.get_slice("_",1)
			check(picture.texture.atlas.resource_path==expected,"active galleries use sketchbook art")
		if DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("sketch-roster/"+screen+".png"))
	app.queue_free();await process_frame
	print("HERO ROSTER: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
