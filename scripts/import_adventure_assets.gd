extends SceneTree
const Pack = preload("res://scripts/enemy_art_import.gd")
func _initialize():
	var enemies: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/adventure_enemies.json"))
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/enemy_visuals.json"))
	var dungeons: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons.json"))
	var done: Array = []
	for definition in enemies.values():
		var id: String = definition.visual
		if id in done: continue
		done.append(id)
		var source = "res://docs/expansion_2026_10/sources/%s_motion.png" % id
		var sheet = Image.load_from_file(source)
		if sheet == null: quit(1); return
		sheet.resize(roundi(sheet.get_width() / 4.0) * 4, roundi(sheet.get_height() / 2.0) * 2, Image.INTERPOLATE_NEAREST)
		var normalized = "user://%s_expansion_sheet.png" % id
		sheet.save_png(normalized)
		if not Pack.motion(normalized, "res://assets/enemies/animations/%s.png" % id): printerr("Cannot pack ",id); quit(1); return
		DirAccess.remove_absolute(normalized)
		if not Pack.cutin("res://docs/expansion_2026_10/sources/%s_cutin.png" % id,"res://assets/comic/enemies/%s.png" % id): quit(1); return
		catalog[id].idle_frames = 4
		catalog[id].attack_frames = 4
		for floor_number in [1,2,3]:
			var dungeon: Dictionary = dungeons[str(floor_number)]
			if definition.get("id", "") in dungeon.common or definition.get("id", "") in [dungeon.elite,dungeon.boss]:
				catalog[id].floor = floor_number
				catalog[id].name = definition.name
				break
	var file = FileAccess.open("res://data/enemy_visuals.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(catalog,"\t")+"\n");file.close()
	for id in ["forest_spring","forest_hunter","forest_spirit","forge_altar","ash_archive","lava_bridge","rest"]:
		var image = Image.load_from_file("res://docs/expansion_2026_10/sources/%s.png" % id)
		if image == null: quit(1); return
		image.resize(1280,720,Image.INTERPOLATE_LANCZOS)
		image.save_png("res://assets/volcano/rest.png" if id == "rest" else "res://assets/encounters/%s.png" % id)
	print("Imported 13 animated enemies, 13 cut-ins, 6 encounters and fortress rest")
	quit()
