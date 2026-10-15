extends RefCounted
# Coordinates the forge view without growing the main screen controller.
static func open(ui: Control) -> void:
	ui.forge_hero = ""
	ui.screen = "forge"
	ui.render()

static func plot(ui: Control) -> void:
	if ui.game.profile.buildings.get("forge", false):
		open(ui)
		return
	var cost = int(ui.game.Forge.config().build_cost)
	if ui.game.profile.souls < cost:
		ui.show_modal("Taller", "Necesitás %d celdas para construirla en el solar 3." % cost, "Entendido", ui.close_modal)
		return
	ui.show_modal("Construir taller", "Por %d celdas, el herrero podrá mejorar permanentemente el equipo de tus héroes." % cost, "Construir", func():
		if ui.game.build_forge():
			ui.close_modal()
			open(ui))

static func build(ui: Control) -> void:
	preload("res://src/ui/screens/forge_screen.gd").build(ui, ui.game.content, ui.game.profile.duplicate(true), ui.forge_hero, ui.game.Forge.config(), ui.game.Forge.levels(ui.game.profile, ui.forge_hero) if ui.forge_hero != "" else {}, {
		"back": ui.open_base_camp,
		"category": func(id): ui.forge_hero = id; ui.render(),
		"buy": func(track, level):
			if ui.game.buy_forge_upgrade(ui.forge_hero, track, level): ui.audio.play_sfx("upgrade")
			ui.render()})
