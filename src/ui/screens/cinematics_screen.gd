extends RefCounted
const Navigation = preload("res://src/ui/cinematic_navigation.gd")
static func build(ui: Control) -> void:
	ui.panel(24,12,1232,90)
	ui.label_at("Historias del retorno",58,30,940,48,32,ui.GOLD)
	ui.button("Inicio",1100,30,130,44,func():ui.screen="home";ui.render())
	ui.label_at("Podés volver a ver el inicio, las historias de los cuatro héroes y los finales descubiertos.",56,108,1168,42,19)
	var clips = Navigation.catalog()
	var index = 0
	for id in clips:
		var clip: Dictionary = clips[id]
		var locked: bool = id.begins_with("boss_") and not ui.game.profile.get("cinematics_seen",{}).has(id)
		var x = 50+(index%5)*238
		var y = 167+(index/5)*256
		var tile = ui.panel(x,y,226,240)
		var art = TextureRect.new()
		art.texture = load(clip.chapters[0].image) if clip.chapters[0].has("image") else load("res://assets/cinematics/%s.png" % clip.background)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		art.modulate = Color(0.3,0.3,0.3) if locked else Color.WHITE
		ui.rect(art,12,12,202,132,tile)
		ui.label_at("Final por descubrir" if locked else clip.title,12,151,202,44,18,ui.GOLD,tile).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		var button = ui.button("Por descubrir" if locked else "Ver historia",22,193,182,40,func():
			await Navigation.play(ui,id)
			Navigation.mark_seen(ui,id),not locked,tile)
		button.name = "ViewCinematic_"+id
		index += 1
