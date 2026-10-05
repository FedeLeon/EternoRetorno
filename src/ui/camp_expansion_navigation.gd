extends RefCounted
const Rules = preload("res://src/rules/camp_expansion.gd")
const Contracts = preload("res://src/rules/expeditions.gd")
const Specs = preload("res://src/rules/specializations.gd")

static func open(ui: Control, building: String) -> void:
	ui.church_hero = ""
	ui.screen = building
	ui.render()

static func plot(ui: Control, building: String) -> void:
	if ui.game.profile.buildings.get(building, false):
		open(ui, building)
		return
	var definition: Dictionary = Rules.buildings()[building]
	if ui.game.profile.souls < int(definition.cost):
		ui.show_modal(definition.name, "Necesitás %d almas para construir este edificio." % definition.cost, "Entendido", ui.close_modal)
		return
	ui.show_modal("Construir " + definition.name, "Costo: %d almas.\n%s" % [definition.cost, "Contratos para tu próxima aventura." if building == "expeditions" else "Especializaciones para héroes que hayan ganado una aventura."], "Construir", func():
		if ui.game.camp_action("build", {"id":building}):
			ui.close_modal()
			open(ui, building))

static func expeditions(ui: Control) -> void:
	var state = ui.game.profile.expeditions
	var offers: Array = []
	var running = ui.active_run()
	var selected = ui.game.run.get("contract", "") if running else state.selected
	for id in state.offers:
		var contract = Contracts.definition(id).duplicate(true)
		contract.progress = Contracts.progress(ui.game.run, contract) if running and selected == id else 0
		offers.append(contract)
	preload("res://src/ui/screens/expeditions_screen.gd").build(ui, {"souls":ui.game.profile.souls, "offers":offers, "selected":selected, "running":running, "last":state.last}, {
		"back":ui.open_base_camp,
		"select":func(id): ui.game.camp_action("contract", {"id":id}); ui.render()})

static func church(ui: Control) -> void:
	var state = ui.game.profile.specializations
	var options: Array = []
	var definitions = Specs.catalog()
	for id in definitions:
		if definitions[id].hero != ui.church_hero: continue
		var spec: Dictionary = definitions[id].duplicate(true)
		spec.id = id
		spec.owned = id in state.owned
		options.append(spec)
	preload("res://src/ui/screens/church_screen.gd").build(ui, {"souls":ui.game.profile.souls, "heroes":ui.game.content.heroes, "hero":ui.church_hero, "options":options, "eligible":ui.church_hero in state.victorious, "active":state.active.get(ui.church_hero, "")}, {
		"back":ui.open_base_camp,
		"hero":func(id): ui.church_hero = id; ui.render(),
		"buy":func(id):
			if ui.game.camp_action("buy_specialization", {"id":id}): ui.audio.play_sfx("upgrade")
			ui.render(),
		"activate":func(id): ui.game.camp_action("activate_specialization", {"hero":ui.church_hero, "id":id}); ui.render()})
