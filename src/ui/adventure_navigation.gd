extends RefCounted
# Resolve the UI only. Saved phases, available edges and rewards remain in Game.
const MapScreen = preload("res://src/ui/screens/map_screen.gd")
const PathsScreen = preload("res://src/ui/screens/paths_screen.gd")

static func has_paths(game: RefCounted) -> bool:
	if game.run.is_empty() or game.run.phase != "map": return false
	# rooms_completed survives a floor transition; fresh adventures still start on the map.
	return game.run.boss_defeated or ((int(game.run.current) >= 0 or int(game.run.get("rooms_completed", 0)) > 0) and not game.available_nodes().is_empty())

static func screen_for(game: RefCounted) -> String:
	return "paths" if has_paths(game) else game.run.phase

static func build(ui: Control, paths: bool) -> void:
	var view = PathsScreen.new() if paths else MapScreen.new()
	view.name = "PathsScreen" if paths else "MapScreen"
	view.nodes = ui.game.run.nodes.duplicate(true)
	view.available = ui.game.available_nodes().duplicate()
	view.visited = ui.game.run.visited.duplicate()
	view.current = ui.game.run.current
	view.run_seed = ui.game.run.seed
	view.floor_number = int(ui.game.run.get("floor", 1))
	view.boss_defeated = ui.game.run.boss_defeated
	view.dungeon_name = ui.Dungeon.definition(view.floor_number).name
	view.exit_caption = ("Entrar al cinturón" if view.floor_number == 1 else "Entrar a la central") if view.floor_number < int(ui.game.run.get("floor_count", 1)) else "Completar aventura"
	view.deck_count = ui.game.run.deck.size()
	view.relics = ui.equipped_relics()
	view.paths_available = has_paths(ui.game)
	view.map_open = not paths
	for hero in ui.game.run.heroes:
		var snapshot = hero.duplicate(true)
		snapshot.title = ui.game.content.heroes[hero.id].name
		snapshot.visual = ui.ANIMATED_HEROES[hero.id]
		view.heroes.append(snapshot)
	view.room_requested.connect(func(id): preload("res://src/ui/map_room_prompt.gd").enter(ui, id))
	view.deck_requested.connect(ui.open_deck)
	view.menu_requested.connect(ui.pause_menu)
	view.descend_requested.connect(func(): ui.act(ui.game.descend))
	view.map_requested.connect(func():
		ui.screen = "map" if paths else screen_for(ui.game)
		ui.render())
	ui.rect(view, 0, 0, 1280, 720)
	if not paths and preload("res://src/rules/building_projects.gd").owned(ui.game.profile, "scouting"):
		var scout = ui.button("Reconocer caminos · 20 celdas", 52, 90, 340, 40, func():
			if ui.game.polish_action("scout"): ui.render(), ui.game.profile.souls >= 20 and view.available.any(func(i): return not ui.game.run.nodes[i].get("scouted", false)))
		scout.name = "ScoutPaths"
