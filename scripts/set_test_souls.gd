extends SceneTree
# Explicit local-only development utility; never runs during normal game startup.
func _initialize() -> void:
	var game = preload("res://src/game.gd").new()
	game.profile.souls = 100000
	if not game.store.write(game.profile, game.run):
		printerr(game.store.last_error)
		quit(1)
		return
	var saved = game.store.read()
	assert(saved.profile.souls == 100000 and saved.run == game.run)
	print("Saldo local: 100000 almas. Aventura conservada. ", ProjectSettings.globalize_path(game.store.path))
	quit()
