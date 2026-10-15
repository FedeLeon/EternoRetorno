extends RefCounted
## Read-only, searchable gallery; undiscovered names remain hidden.
static func build(ui: Control) -> void:
	var bg = TextureRect.new()
	bg.texture = preload("res://assets/collection/background.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(bg,0,0,1280,720)
	preload("res://src/ui/components/preparation_header.gd").build(ui,"Bestiario descubierto",ui.back,-1,"Inicio" if ui.return_screen == "home" else "Campamento")
	ui.panel(36,94,1208,96)
	var records: Dictionary = ui.game.profile.get("bestiary",{}).duplicate(true)
	var count = ui.game.content.enemies.keys().filter(func(id):return not records.get(id,{}).is_empty()).size()
	ui.label_at("%d / %d unidades descubiertas" % [count,ui.game.content.enemies.size()],54,101,510,28,18,ui.GOLD)
	var search = LineEdit.new()
	search.name = "BestiarySearch"
	search.placeholder_text = "Buscar unidad descubierta…"
	search.clear_button_enabled = true
	ui.rect(search,796,100,426,38)
	var state = {"floor":0,"known":true,"query":""}
	var body = Control.new()
	body.name = "BestiaryEntries"
	var scroll = ScrollContainer.new()
	scroll.name = "BestiaryScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui.rect(scroll,36,204,1208,488)
	scroll.add_child(body)
	var tabs: Array[Button] = []
	var group = ButtonGroup.new()
	var rebuild = func():
		populate(ui,body,records,state)
		scroll.scroll_vertical = 0
	for i in range(4):
		var index = i
		var button = ui.button(["Todos","Mantenimiento","Industria","Central"][i],54+i*154,144,142,34,func():state.floor=index;rebuild.call())
		button.name = "BestiaryFloor%d" % i
		button.toggle_mode = true
		button.button_group = group
		button.button_pressed = i == 0
		button.add_theme_font_size_override("font_size",16)
		tabs.append(button)
	var known = CheckButton.new()
	known.name = "BestiaryKnownOnly"
	known.text = "Solo descubiertos"
	known.button_pressed = true
	known.add_theme_font_size_override("font_size",16)
	ui.rect(known,796,144,426,34)
	known.toggled.connect(func(value):state.known=value;rebuild.call())
	search.text_changed.connect(func(value):state.query=value.strip_edges().to_lower();rebuild.call())
	rebuild.call()

static func populate(ui: Control, body: Control, records: Dictionary, state: Dictionary) -> void:
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()
	var allowed: Array = ui.game.content.enemies.keys()
	if int(state.floor) > 0:
		var dungeon = preload("res://src/dungeon.gd").definition(int(state.floor))
		allowed = dungeon.common.duplicate()
		allowed.append_array([dungeon.elite,dungeon.boss])
	var ids = allowed.filter(func(id):
		var discovered = not records.get(id,{}).is_empty()
		if state.known and not discovered: return false
		if not state.query.is_empty(): return discovered and state.query in ui.game.content.enemies[id].name.to_lower()
		return true)
	ids.sort_custom(func(a,b):
		var known_a = not records.get(a,{}).is_empty()
		var known_b = not records.get(b,{}).is_empty()
		if known_a != known_b: return known_a
		return ui.game.content.enemies[a].name.naturalnocasecmp_to(ui.game.content.enemies[b].name) < 0)
	body.custom_minimum_size = Vector2(1180,maxi(220,ceili(ids.size()/3.0)*208))
	if ids.is_empty():
		var message = ui.label_at("No hay unidades descubiertas que coincidan con esta búsqueda.",80,92,1000,62,22,ui.MUTED,body)
		message.name = "BestiaryEmpty"
		message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		return
	for i in range(ids.size()):
		var id: String = ids[i]
		var record: Dictionary = records.get(id,{})
		var definition: Dictionary = ui.game.content.enemies[id]
		var row = ui.panel((i%3)*393,(i/3)*208,377,194,ui.GOLD,body)
		row.name = "BestiaryEntry_"+id
		if record.is_empty():
			ui.label_at("?\nSin descubrir",20,38,337,110,26,ui.MUTED,row).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			continue
		var actor = ui.EnemySprite.new()
		actor.visual_id = definition.visual
		ui.rect(actor,-8,58,128,126,row)
		ui.label_at(definition.name,110,12,251,48,18,ui.GOLD,row)
		var attacks: Array[String] = []
		var blocks: Array[String] = []
		for intent in definition.pattern:
			attacks.append(str(int(intent.get("damage",0))))
			blocks.append(str(int(intent.get("block",0))))
		var role = {"protector":"Protege a sus compañeros.","support":"Restaura vida a sus aliados.","attacker":"Ataca según su intención."}.get(definition.get("role","attacker"),"Observá su intención.")
		var text = "%d PV base · %s\n%s\nAtaque %s · bloqueo %s\nEncontrado %d · derrotado %d" % [definition.hp,"Guardián" if definition.get("boss",false) else "Criatura",role,"/".join(attacks),"/".join(blocks),record.get("encounters",0),record.get("kills",0)]
		ui.label_at(text,110,64,251,116,15,ui.TEXT,row)
