extends RefCounted
static func start(ui: Control, party: Array, weapon: int, armor: int) -> void:
	if party.size() != 2 or not preload("res://src/rules/training_config.gd").validate(ui.game,ui.training_config): return
	if ui.training_original == null: ui.training_original = ui.game
	var sandbox = preload("res://src/game.gd").new("user://training-never-saved", false)
	sandbox.profile = ui.training_original.profile.duplicate(true)
	sandbox.new_run(party, 777)
	sandbox.run.training = true
	sandbox.run.tactics_version = 1 if not ui.training_config.get("enemies",[]).is_empty() else 0
	sandbox.run.training_config = ui.training_config.duplicate(true)
	for hero in sandbox.run.heroes: hero.forge = {"weapon":weapon, "armor":armor, "strength":weapon * int(ui.game.Forge.config().strength_per_level), "block":armor * int(ui.game.Forge.config().block_per_level)}
	ui.game = sandbox
	reset(ui)

static func reset(ui: Control) -> void:
	for hero in ui.game.run.heroes: hero.hp = hero.max_hp; hero.block = 0
	ui.game.run.phase = "map"
	ui.game.run.current = -1
	ui.game.run.visited = []
	var id = ui.game.content.enemies.keys()[0]
	var config: Dictionary = ui.game.run.get("training_config",{})
	ui.game.run.nodes[0].encounter = config.get("enemies",[]).duplicate() if not config.get("enemies",[]).is_empty() else [id]
	ui.game.enter_node(0)
	if config.get("enemies",[]).is_empty():
		var enemy = ui.game.run.combat.enemies[0]
		enemy.hp = 500;enemy.max_hp = 500
		enemy.intent = preload("res://src/rules/training_config.gd").intent(ui.game,enemy,{"target":0})
	ui.game.run.combat.energy = 99
	if config.get("enemies",[]).is_empty(): ui.game.content.enemies[id].name = "Maniquí de práctica"
	ui.screen = "combat"
	ui.selected_card = -1
	ui.render()

static func leave(ui: Control) -> void:
	if ui.game.run.has("guided_lesson"):
		preload("res://src/ui/guided_practice_navigation.gd").finish(ui, false); return
	if ui.training_original != null:
		ui.game = ui.training_original
		ui.training_original = null
	ui.open_base_camp()

static func toolbar(ui: Control) -> void:
	ui.button("Elegir cartas", 180, 70, 170, 34, func():
		if ui.combat_busy: return
		cards(ui))
	ui.button("Reiniciar", 365, 70, 130, 34, func():
		if not ui.combat_busy: reset(ui))
	ui.button("Salir del entrenamiento", 510, 70, 260, 34, func():
		if not ui.combat_busy: leave(ui))

static func cards(ui: Control) -> void:
	ui.close_modal()
	var overlay = Control.new()
	overlay.z_as_relative = false; overlay.z_index = 200
	ui.rect(overlay, 0, 0, 1280, 720, ui)
	ui.overlay = overlay
	var shade = ColorRect.new(); shade.color = Color(0,0,0,0.85)
	ui.rect(shade, 0,0,1280,720,overlay)
	ui.panel(30,30,1220,660,ui.GOLD,overlay)
	ui.label_at("Añadí cartas a tu mano para probarlas", 60,40,860,50,26,ui.GOLD,overlay)
	ui.button("Volver",1050,44,160,42,ui.close_modal,true,overlay)
	var scroll = ScrollContainer.new(); ui.rect(scroll,50,110,1180,550,overlay)
	var contents = Control.new(); scroll.add_child(contents)
	var ids: Array = ui.game.content.cards.keys().filter(func(id): return ui.game.content.cards[id].owner in ui.game.run.party)
	contents.custom_minimum_size = Vector2(1150,ceil(ids.size()/5.0)*300)
	for i in range(ids.size()):
		var id = ids[i]
		ui.card_panel({"id":id,"upgraded":false}, (i%5)*229, (i/5)*300,220,284,func():
			ui.game.run.combat.hand.append({"id":id,"upgraded":false})
			ui.game.run.combat.energy = 99
			ui.close_modal();ui.render(),false,true,contents)
