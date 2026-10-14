extends RefCounted
static func build(ui: Control) -> void:
	var bg = TextureRect.new(); bg.texture = load("res://assets/projects/interior.png"); bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(bg,0,0,1280,720)
	preload("res://src/ui/components/preparation_header.gd").build(ui,"Proyectos del campamento",ui.open_base_camp,ui.game.profile.souls,"Campamento")
	var rules = preload("res://src/rules/building_projects.gd")
	var ids = rules.PROJECTS.keys()
	for i in range(ids.size()):
		var id: String = ids[i]; var project: Dictionary = rules.PROJECTS[id]
		var tile = ui.panel(60+i*392,160,376,466)
		var art = TextureRect.new(); art.texture = load("res://assets/base_camp/dusk/%s.png" % project.building)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED;art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(art,35,22,306,170,tile)
		ui.label_at(project.name,24,200,328,68,23,ui.GOLD,tile).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ui.label_at(project.description,24,282,328,100,20,ui.TEXT,tile).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var owned = rules.owned(ui.game.profile,id)
		var built: bool = ui.game.profile.buildings.get(project.building,false)
		ui.button("Completado" if owned else ("Construí el edificio primero" if not built else "Desarrollar · %d almas" % project.cost),24,394,328,48,func():
			if ui.game.polish_action("project",{"id":id}): ui.audio.play_sfx("upgrade");ui.render(),not owned and built and ui.game.profile.souls >= project.cost,tile).add_theme_font_size_override("font_size",18)
