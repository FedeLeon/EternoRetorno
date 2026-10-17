extends SceneTree
const Game = preload("res://src/game.gd")
const Actor = preload("res://src/presentation/detailed_hero.gd")
const CutIn = preload("res://src/presentation/hero_cut_in.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ", message)
func shot(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("visual_polish_16/" + id + ".png"))
func pixels_different(a: Image, b: Image) -> int:
	var count = 0
	for y in range(a.get_height()):
		for x in range(a.get_width()):
			if a.get_pixel(x, y) != b.get_pixel(x, y): count += 1
	return count
func unlock_gallery(entries: Array) -> void:
	if DisplayServer.get_name() == "headless": return
	var page = Control.new(); root.add_child(page)
	var bg = ColorRect.new(); bg.color = Color("152131"); bg.size = Vector2(1280, 720); page.add_child(bg)
	var icons = entries.duplicate()
	icons.append({"name":"Desbloqueos", "icon":"res://assets/collection/unlocks/unlocks_tab.png"})
	for i in range(icons.size()):
		var image = TextureRect.new(); image.texture = load(icons[i].icon)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.position = Vector2(38 + (i % 5) * 250, 12 + (i / 5) * 234); image.size = Vector2(180, 180)
		page.add_child(image)
		var label = Label.new(); label.text = icons[i].name; label.position = image.position + Vector2(-10, 186)
		label.size = Vector2(220, 35); label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; label.add_theme_font_size_override("font_size", 16)
		page.add_child(label)
	await shot("unlock_icons")
	page.queue_free(); await process_frame
func breathing_render() -> void:
	if DisplayServer.get_name() == "headless": return
	var viewport = SubViewport.new()
	viewport.size = Vector2i(256, 256); viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var actor = Actor.new(); actor.size = Vector2(256, 240)
	viewport.add_child(actor); actor.set_process(false)
	actor.idle_motion.advance(0.13)
	await RenderingServer.frame_post_draw
	var first = viewport.get_texture().get_image()
	actor.idle_motion.advance(0.95)
	await RenderingServer.frame_post_draw
	var second = viewport.get_texture().get_image()
	actor.idle_motion.advance(0.001)
	await RenderingServer.frame_post_draw
	var near = viewport.get_texture().get_image()
	var movement = pixels_different(first, second)
	check(movement > 100, "native rendered guard changes authored drawing")
	check(pixels_different(second, near) < movement / 3, "sub-frame times do not jump between poses")
	check(preload("res://src/presentation/hero_grounding.gd").bottom(actor.sprite.sprite_frames.get_frame_texture("idle",actor.sprite.frame)) == 240, "authored guard feet stay planted")
	viewport.queue_free(); await process_frame
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	await breathing_render()
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-polish16", false)
	root.add_child(app)
	for floor_number in [1, 2, 3]:
		app.game.new_run(["warrior", "mage"], 82, {}, floor_number)
		app.game.enter_node(0); app.screen = "combat"; app.render(); await process_frame
		var scenery = app.layer.get_node("DungeonScenery")
		check(scenery.self_modulate == preload("res://src/ui/components/battle_background.gd").SCENERY_TINT, "all dungeon backgrounds are darker")
		check(app.layer.modulate.r == 1.0 and app.layer.modulate.g == 1.0 and app.layer.modulate.b == 1.0, "scene tint is not inherited by the UI")
		check(app.hero_art.values().all(func(a): return a.modulate == Color.WHITE), "heroes retain their original color and brightness")
		await shot("floor_%d" % floor_number)
	var rng_before = app.game.rng.state
	CutIn.attack_cycles.clear()
	for hero in CutIn.COLORS:
		var variants = {}; var signatures = {}; var previous = ""
		for i in range(6):
			var effect = CutIn.play(app.layer, hero, "attack")
			await process_frame
			check(effect.texture_path != previous, "no consecutive duplicate attack for " + hero)
			previous = effect.texture_path; variants[previous] = true
			check(effect.static_illustration and effect.frame_grid == Vector2i.ONE, "all variants remain static with separate live lights")
			var image = effect.picture.texture.get_image()
			signatures[hash(image.get_data())] = true
			check(image.get_size() == Vector2i(1536, 1024) and image.get_pixel(0, 0).a < 0.05, "HD foreground and transparent exterior")
			if i < 3:
				effect.set_process(false); effect._process(0.35); await shot("%s_variant_%d" % [hero, i])
			effect.queue_free(); await process_frame
		check(variants.size() == 3 and signatures.size() == 3, "three genuinely different pictures per hero")
	check(app.game.rng.state == rng_before, "art variation does not consume gameplay RNG")
	app.screen = "collection"; app.render(); await process_frame
	var collection = app.layer.get_node("CollectionScreen")
	var icons = {}
	for entry in collection.snapshot.unlocks:
		check(entry.icon.begins_with("res://assets/collection/unlocks/"), "every unlock has dedicated comic artwork")
		var texture = load(entry.icon)
		check(texture is Texture2D and texture.get_size() == Vector2(256, 256), "complete icon at detail resolution")
		icons[hash(texture.get_image().get_data())] = true
	check(icons.size() == collection.snapshot.unlocks.size() and icons.size() == 14, "four cards, timer and nine relics all have distinct icons")
	collection.tabs[1].pressed.emit(); await process_frame; await shot("unlocks")
	await unlock_gallery(collection.snapshot.unlocks)
	print("VISUAL POLISH 16: %d checks / %d failures" % [checks, failures])
	app.queue_free(); await process_frame; Actor.cache.clear()
	quit(1 if failures else 0)
