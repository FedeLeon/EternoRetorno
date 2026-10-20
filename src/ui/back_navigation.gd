extends RefCounted
## Presentation navigation only. Never rewind adventure progression or mutate saves.
var last_screen = ""
var origins: Dictionary = {}
const AUXILIARY = ["options","collection","cinematics"]
const RETURNABLE = ["base_camp","select","equipment","market","forge","church","expeditions","training_setup","refuge","bonds","bestiary","collection","options","cinematics","items"]

func observe(ui: Control) -> void:
	if ui.screen == last_screen: return
	if ui.screen in AUXILIARY:
		origins[ui.screen] = last_screen if last_screen != "" else "home"
	last_screen = ui.screen

func can_return(ui: Control) -> bool:
	if ui.screen in RETURNABLE: return true
	if ui.screen == "deck": return ui.return_screen != "deck" and ui.return_screen != ""
	return ui.screen == "map" and preload("res://src/ui/adventure_navigation.gd").has_paths(ui.game)

func back(ui: Control) -> void:
	var hud = ui.layer.get_node_or_null("CombatHUD")
	if is_instance_valid(hud) and hud.close_relic():
		return
	if ui.combat_busy:
		return
	var treasure = ui.layer.get_node_or_null("TreasureScreen")
	if is_instance_valid(treasure) and treasure.busy:
		return
	if is_instance_valid(treasure) and treasure.result.get("opened", false) and not is_instance_valid(ui.overlay):
		treasure.continue_requested.emit()
		return
	if is_instance_valid(ui.overlay):
		ui.close_modal()
	elif ui.screen == "home":
		ui.show_modal("Cerrar el libro", "Tu progreso está guardado.", "Salir del juego", func(): ui.game.checkpoint(); ui.get_tree().quit())
	elif ui.screen == "bonds":
		ui.screen = "refuge"; ui.render()
	elif ui.screen == "refuge":
		ui.layer.get_node("RefugeScreen").go_back()
	elif ui.screen == "items":
		ui.continue_run()
	elif ui.screen == "equipment":
		ui.screen = "select"
		ui.render()
	elif ui.screen == "market" and ui.market_hero != "":
		ui.market_hero = ""
		ui.render()
	elif ui.screen == "forge" and ui.forge_hero != "":
		ui.forge_hero = ""
		ui.render()
	elif ui.screen == "church" and ui.church_hero != "":
		ui.church_hero = ""
		ui.render()
	elif ui.screen == "bestiary" and ui.return_screen == "home":
		ui.screen = "home"; ui.render()
	elif ui.screen in ["select", "market", "forge", "church", "expeditions", "training_setup", "bestiary"]:
		ui.open_base_camp()
	elif ui.screen in ["collection", "options", "cinematics"]:
		ui.screen = origins.get(ui.screen,"home")
		last_screen = ui.screen # Returning must not replace an auxiliary parent with its child.
		ui.render()
	elif ui.screen == "base_camp":
		ui.screen = "home"
		ui.render()
	elif ui.screen == "map" and preload("res://src/ui/adventure_navigation.gd").has_paths(ui.game):
		ui.continue_run()
	elif ui.screen == "deck":
		ui.screen = ui.return_screen
		ui.upgrade_mode = false
		ui.render()
	elif ui.screen == "combat" and (ui.selected_card >= 0 or ui.selected_synergy != ""):
		ui.selected_card = -1
		ui.selected_synergy = ""
		ui.render()
	else:
		ui.pause_menu()

