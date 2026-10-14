extends RefCounted
# Background composition only; screens that own their scenery bypass this helper.
static func build(ui: Control) -> void:
	if ui.screen == "cinematics":
		var backdrop = TextureRect.new()
		backdrop.texture = preload("res://assets/cinematics/intro.png")
		backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		backdrop.modulate = Color(0.28,0.28,0.32)
		backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(backdrop,0,0,1280,720)
		return
	if ui.screen in ["bonds", "event_cards"]:
		var picture = TextureRect.new()
		picture.texture = load("res://assets/refuge/interior.png" if ui.screen == "bonds" else "res://assets/encounters/%s.png" % ui.game.run.nodes[ui.game.run.current].event)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(picture, 0, 0, 1280, 720)
		var shadow = ColorRect.new(); shadow.color = Color(0, 0, 0, 0.7)
		shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(shadow, 0, 0, 1280, 720)
		return
	if ui.screen == "room" and ui.game.run.nodes[ui.game.run.current].kind == "event":
		return # Encounter scenes provide their own illustrated background.
	if ui.screen in ["map", "equipment", "refuge", "collection"]:
		return # These screens own their backgrounds.
	if ui.screen == "combat" or (ui.screen == "room" and int(ui.game.run.get("floor", 1)) == 2):
		var room = TextureRect.new()
		room.texture = load("res://assets/combat_depth/training.png" if ui.game.run.get("training", false) else ui.BattleBackground.path_for(ui.game.run.seed, ui.game.run.current, int(ui.game.run.get("floor", 1))))
		room.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		room.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(room, 0, 64, 1280, 656)
		if ui.screen == "combat" and not ui.game.run.get("training",false):
			var atmosphere = preload("res://src/presentation/battle_atmosphere.gd").new()
			atmosphere.name = "BattleAtmosphere"
			atmosphere.floor_number = int(ui.game.run.get("floor",1))
			ui.rect(atmosphere,0,0,1280,720)
		return
	if ui.screen in ["home", "options"]:
		var title = TextureRect.new()
		title.texture = preload("res://assets/title/background.png")
		title.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(title, 0, 0, 1280, 720)
		return
	if ui.screen == "base_camp":
		var camp = TextureRect.new()
		camp.texture = preload("res://assets/base_camp/dusk/background.png")
		camp.name = "DayCampBackground"
		var ambience = ShaderMaterial.new()
		ambience.shader = preload("res://assets/shaders/camp_dusk.gdshader")
		camp.material = ambience
		camp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		camp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(camp, 0, 80, 1280, 640)
		return
	if ui.screen == "select":
		var camp = TextureRect.new()
		camp.texture = preload("res://assets/camp/background.png")
		camp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		camp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(camp, 0, 0, 1280, 720)
		return
	var bg = ui.Art.new()
	ui.rect(bg, 0, 0, 1280, 720)
	var shade = ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.06, 0.44)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(shade, 0, 0, 1280, 720)
