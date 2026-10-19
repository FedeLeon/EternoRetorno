extends SceneTree
const CutIn = preload("res://src/presentation/enemy_cut_in.gd")
const Preferences = preload("res://src/presentation/preferences.gd")
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func verify() -> void:
	root.size = Vector2i(1280,720)
	Preferences.settings = {"reduce_cutins":false,"low_effects":true}
	var host = Control.new()
	root.add_child(host)
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var visuals:Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/enemy_visuals.json"))
	var content = preload("res://src/content.gd").new()
	for id in content.enemies:
		for action in ["attack","defense"]:
			check(not CutIn.artwork(content.enemies[id].visual,action).is_empty(),"enemy has foreground action: "+id+"/"+action)
	var seen = {}
	var ids = visuals.keys()
	ids.sort()
	for visual in ids:
		for action in ["attack","defense"]:
			var effect = CutIn.play(host,visual,action)
			check(effect != null,"foreground exists: "+visual+"/"+action)
			if effect == null: continue
			effect._process(.10)
			check(effect.action == action and effect.visual_id == visual,"action and identity preserved")
			check(effect.texture_path == visuals[visual].foreground[action],"runtime uses dedicated action mapping")
			check(effect.defensive_effect == (action == "defense"),"defense art receives defense lighting")
			check(effect.static_illustration and effect.frame_grid == Vector2i.ONE and not effect.picture.texture is AtlasTexture,"single static illustration per action")
			check(effect.align_right and effect.from_right,"enemy foreground remains on the right")
			var image = effect.picture.texture.get_image()
			check(image.get_size() == Vector2i(768,512) and image.get_pixel(0,0).a == 0,"HD alpha cutout")
			check(not seen.has(effect.texture_path),"no shared attack/defense or cross-machine fallback")
			seen[effect.texture_path] = true
			var position = effect.picture.position
			effect._process(.05)
			check(effect.picture.position == position and effect.picture.scale == Vector2.ONE,"foreground artwork stays static")
			effect._process(effect.duration)
			check(effect.completed,"effect finishes normally")
			await process_frame
			check(not is_instance_valid(effect),"foreground cleans up")
	check(seen.size() == visuals.size()*2,"all 112 machine action assets covered")
	check(CutIn.play(host,"missing_machine") == null,"unknown machine never falls back to unrelated art")
	check(CutIn.play(host,ids[0],"invalid_action") == null,"unsupported action rejected")
	Preferences.settings.reduce_cutins = true
	check(CutIn.play(host,ids[0]) == null,"cut-in preference respected")
	Preferences.settings.reduce_cutins = false
	host.queue_free()
	await process_frame
	if DisplayServer.get_name() != "headless":
		await galleries(ids,visuals)
		await battle_previews(content)
	print("ENEMY FOREGROUND PAIRS: %d checks / %d failures"%[checks,failures])
	quit(1 if failures else 0)
func picture(texture:Texture2D,rect:Rect2,parent:Control) -> void:
	var view = TextureRect.new()
	view.texture = texture
	view.position = rect.position
	view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	view.size = rect.size
	view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	parent.add_child(view)
	view.size = rect.size
func galleries(ids:Array,visuals:Dictionary) -> void:
	for start in range(0,ids.size(),4):
		var page = Control.new()
		root.add_child(page)
		var bg = ColorRect.new()
		bg.color = Color("151620")
		bg.size = Vector2(1280,720)
		page.add_child(bg)
		for i in range(mini(4,ids.size()-start)):
			var visual:String = ids[start+i]
			var origin = Vector2((i%2)*640,(i/2)*360)
			var label = Label.new()
			label.text = visual+"      Modelo / Ataque / Defensa"
			label.position = origin+Vector2(6,4)
			label.add_theme_font_size_override("font_size",17)
			page.add_child(label)
			var reference = load("res://assets/combat_static/enemies/%s/idle.png"%visual).get_image()
			reference = reference.get_region(Pack.bounds(reference,.5))
			picture(ImageTexture.create_from_image(reference),Rect2(origin+Vector2(4,40),Vector2(120,285)),page)
			picture(load(visuals[visual].foreground.attack),Rect2(origin+Vector2(130,40),Vector2(246,290)),page)
			picture(load(visuals[visual].foreground.defense),Rect2(origin+Vector2(386,40),Vector2(246,290)),page)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("enemy_cutins_review/review_%02d.png"%(start/4)))
		page.queue_free()
		await process_frame
func battle_previews(content:RefCounted) -> void:
	var app = load("res://main.tscn").instantiate()
	app.game = preload("res://src/game.gd").new("user://foreground-pairs-preview.save",false)
	app.game.profile.tutorial_complete = true
	root.add_child(app)
	for visual in ["elemental_1","crypt_beetle","flying_4","skeleton_4"]:
		app.game.new_run(["warrior","guardian"],42)
		app.game.enter_node(0)
		var id = content.enemies.keys().filter(func(k):return content.enemies[k].visual == visual)[0]
		app.game._start_combat([id])
		app.continue_run()
		await process_frame
		for action in ["attack","defense"]:
			var effect = CutIn.play(app.layer,visual,action)
			effect._process(.22)
			effect.set_process(false)
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("enemy_cutins_review/battle_%s_%s.png"%[visual,action]))
			effect.queue_free()
			await process_frame
	app.queue_free()
	await process_frame
