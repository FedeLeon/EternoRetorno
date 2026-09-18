extends RefCounted
const Starters = preload("res://src/rules/starter_decks.gd")
static func build(ui: Control) -> void:
	var choices = {}
	for hero in ui.game.content.heroes:
		choices[hero] = {"attacks":Starters.attack_count(ui.game.profile, hero), "starter":ui.game.content.heroes[hero].starter.duplicate()}
	var view = preload("res://src/ui/screens/refuge_screen.gd").new()
	view.ui = ui
	view.heroes = ui.game.content.heroes.duplicate(true)
	view.choices = choices
	view.souls = ui.game.profile.souls
	view.back_requested.connect(ui.open_base_camp)
	view.save_requested.connect(func(hero, attacks):
		if ui.game.configure_starter(hero, attacks): view.saved(attacks))
	ui.rect(view, 0, 0, 1280, 720)
