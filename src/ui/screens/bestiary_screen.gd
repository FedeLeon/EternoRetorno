extends RefCounted
# Discovered enemy information, supplied by persisted encounter records.
static func build(ui: Control) -> void:
	var bg = TextureRect.new()
	bg.texture = preload("res://assets/collection/background.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(bg, 0, 0, 1280, 720)
	preload("res://src/ui/components/preparation_header.gd").build(ui,"Bestiario descubierto",ui.back,-1,"Inicio" if ui.return_screen == "home" else "Campamento")
	ui.panel(36,94,1208,38)
	ui.label_at("Las criaturas revelan su información al encontrarlas.",54,95,1172,36,18,ui.TEXT)
	var scroll = ScrollContainer.new()
	ui.rect(scroll, 36, 145, 1208, 540)
	var body = Control.new()
	body.custom_minimum_size = Vector2(1180, ceil(ui.game.content.enemies.size() / 3.0) * 190)
	scroll.add_child(body)
	var ids = ui.game.content.enemies.keys()
	for i in range(ids.size()):
		var id = ids[i]
		var record: Dictionary = ui.game.profile.get("bestiary", {}).get(id, {})
		var def: Dictionary = ui.game.content.enemies[id]
		var row = ui.panel((i % 3) * 393, (i / 3) * 190, 377, 176, ui.GOLD, body)
		if record.is_empty():
			ui.label_at("?\nSin descubrir", 20, 35, 337, 110, 26, ui.MUTED, row).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			continue
		var art = ui.EnemySprite.new()
		art.visual_id = def.visual
		ui.rect(art, -18, 25, 128, 132, row)
		ui.label_at(def.name, 110, 12, 253, 38, 19, ui.GOLD, row)
		var damage: Array[String] = []
		var guard: Array[String] = []
		for intent in def.pattern:
			damage.append(str(int(intent.get("damage", 0)))); guard.append(str(int(intent.get("block", 0))))
		var roles = {"protector":"Protege a sus aliados con bloqueo.","support":"Cura a sus aliados.","attacker":"Ataca según su intención."}
		ui.label_at("%d PV base · %s\n%s\nEncontrado %d · derrotado %d" % [def.hp, "Guardián" if def.get("boss", false) else "Criatura", roles.get(def.get("role", "attacker"), "Observá su intención.") + "\nAtaque " + "/".join(damage) + " · bloqueo " + "/".join(guard), record.encounters, record.kills], 110, 54, 253, 106, 16, ui.TEXT, row)
