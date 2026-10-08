extends SceneTree
const Game = preload("res://src/game.gd")
var failures = 0
func _initialize(): call_deferred("run_tests")
func check(ok: bool, message: String):
 if not ok:
  failures += 1
  printerr(message)
func run_tests():
 var path = "user://development-start-test.save"
 for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
 var game = Game.new(path, true)
 game.new_run(["warrior", "cleric"], 42)
 check(game.run.floor == 1, "default stays crypt")
 var snapshot = game.run.duplicate(true)
 check(not game.new_run(["warrior", "cleric"], 42, {}, 4) and game.run == snapshot, "invalid floor preserves run")
 var app = load("res://main.tscn").instantiate()
 app.game = game
 root.add_child(app)
 app.selected_party = ["warrior", "cleric"]
 app.equipped = {"team":"vital_amulet"}
 app.screen = "equipment"
 app.render()
 app.begin()
 await process_frame
 if DisplayServer.get_name() != "headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/development-start.png")
 app.overlay.get_node("CancelDungeonChoice").pressed.emit()
 check(game.run == snapshot, "cancel does not abandon adventure")
 app.begin()
 app.overlay.get_node("StartDungeon2").pressed.emit()
 app.overlay.get_node("StartAdventure").pressed.emit()
 for hero in ["warrior","cleric"]:
  await process_frame
  check(app.has_node("CinematicPlayer"),"selected hero is introduced")
  app.get_node("CinematicPlayer").finish()
 await process_frame
 check(game.run.floor == 2 and game.run.current == -1 and game.available_nodes() == [0], "forest starts at entrance")
 check(game.run.deck.size() == 20 and game.run.inventory.is_empty() and game.run.visited.is_empty(), "fresh starter state")
 check(game.run.team_relic == "vital_amulet" and app.screen == "map", "relic and map preserved")
 var loaded = Game.new(path, true)
 check(loaded.run.floor == 2 and loaded.run.nodes == game.run.nodes, "forest save reload")
 check(game.enter_node(0), "forest entrance playable")
 var roster = preload("res://src/dungeon.gd").definition(2).common
 check(game.run.nodes[0].encounter.all(func(id): return id in roster), "forest encounter roster")
 app.begin()
 app.overlay.get_node("StartDungeon1").pressed.emit()
 app.overlay.get_node("StartAdventure").pressed.emit()
 check(game.run.floor == 1, "crypt selectable after forest")
 for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
 print("DEVELOPMENT START FAILURES: ", failures)
 quit(1 if failures else 0)
