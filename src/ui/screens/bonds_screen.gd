extends RefCounted
const Rules = preload("res://src/rules/adventure_extensions.gd")
static func build(ui: Control, back: Callable) -> void:
	ui.header("Vínculos entre compañeros", "Completá aventuras juntos para descubrir historias y variantes de sus enlaces.")
	var scroll = ScrollContainer.new(); ui.rect(scroll,55,135,1170,490)
	var body = VBoxContainer.new(); body.custom_minimum_size = Vector2(1130,0); body.add_theme_constant_override("separation",12); scroll.add_child(body)
	var heroes: Array = ui.game.content.heroes.keys()
	for i in range(heroes.size()):
		for j in range(i+1,heroes.size()):
			var party: Array = [heroes[i],heroes[j]]
			var key = Rules.pair_key(party)
			var wins = int(ui.game.profile.get("bonds",{}).get(key,0))
			var panel = PanelContainer.new(); panel.custom_minimum_size = Vector2(1130,135); body.add_child(panel)
			panel.add_theme_stylebox_override("panel",preload("res://src/ui/components/dark_skin.gd").dialog())
			var box = VBoxContainer.new(); panel.add_child(box)
			var label = Label.new(); label.text = "%s + %s · %d aventuras juntos" % [ui.game.content.heroes[party[0]].name,ui.game.content.heroes[party[1]].name,wins]; box.add_child(label)
			var story = Label.new(); story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			story.text = dialogue(ui,party,wins); box.add_child(story)
			var choose = OptionButton.new(); choose.disabled = wins == 0
			for text in ["Equilibrado · enlace original","Ofensivo · +4 daño, -3 bloqueo","Protector · -4 daño, +4 bloqueo"]: choose.add_item(text)
			choose.select(["balanced","aggressive","protective"].find(ui.game.profile.get("bond_variants",{}).get(key,"balanced")))
			choose.item_selected.connect(func(index): ui.game.configure_bond(party,["balanced","aggressive","protective"][index]))
			box.add_child(choose)
	ui.button("Volver al Refugio",460,640,360,48,back)
static func dialogue(ui: Control, party: Array, wins: int) -> String:
	if wins == 0: return "Una aventura completa compartida abre este recuerdo."
	var voices = {"warrior":"Yo abro el camino. Avisame cuando necesites cubrirte.","guardian":"Tu espalda estará a salvo mientras yo siga en pie.","rogue":"Ahora sé reconocer tus pasos, incluso en la oscuridad.","mage":"La magia cambia, pero aprendí a confiar en tu ritmo.","cleric":"Cuando el fuego se apaga, todavía podemos sostenernos.","ranger":"Dos huellas juntas encuentran caminos que una sola no ve."}
	return "%s: «%s»\n%s: «%s»%s" % [ui.game.content.heroes[party[0]].name,voices[party[0]],ui.game.content.heroes[party[1]].name,voices[party[1]],"\nEl recuerdo de tres victorias: ya no hace falta hablar para luchar juntos." if wins >= 3 else ""]
