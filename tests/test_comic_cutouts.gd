extends SceneTree
const Outline = preload("res://src/presentation/comic_outline.gd")
const Game = preload("res://src/game.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",message)
func verify() -> void:
	root.size = Vector2i(1280,720)
	await render_probe()
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-comic-cutouts",false); root.add_child(app)
	for floor_number in [1,2,3]:
		app.game.new_run(["warrior","mage"] if floor_number==1 else ["guardian","rogue"],82,{},floor_number)
		app.game.enter_node(0)
		var before = app.game.run.duplicate(true); var rng = app.game.rng.state
		app.screen="combat";app.render();await process_frame;await process_frame
		check(app.layer.has_node("ComicPageMargin"),"level has inked vignette margin")
		check(app.layer.get_node("ComicPageMargin").mouse_filter==Control.MOUSE_FILTER_IGNORE,"vignette cannot block inputs")
		for actor in app.hero_art.values()+app.enemy_art.values():
			var texture:Texture2D=actor.sprite.sprite_frames.get_frame_texture(actor.sprite.animation,actor.sprite.frame) if actor.sprite is AnimatedSprite2D else actor.sprite.texture
			check(Outline.is_baked(texture) or (actor.sprite.material is ShaderMaterial and actor.sprite.material.get_shader_parameter("cutout_enabled")),"battle actors have paper edge")
			var old_scale = actor.scale
			var old_pos = actor.position
			actor.sprite.frame=1
			if actor.sprite.material is ShaderMaterial:
				check(actor.sprite.material.get_shader_parameter("cutout_region").z<1,"outline stays within current atlas cell")
				if Outline.is_baked(texture):check(not actor.sprite.material.get_shader_parameter("cutout_enabled"),"baked paper rim skips extra sampling and a second outline")
			check(actor.scale==old_scale and actor.position==old_pos,"outline cannot change scale or grounding")
		var attack = app.layer.get_node("EnemyIntent0/Attack").get_child(0)
		check(Outline.is_baked(attack.texture) or attack.material is ShaderMaterial,"attack icon has same cutout finish")
		check(app.game.run==before and app.game.rng.state==rng,"visual decoration leaves save and RNG unchanged")
	var cutin = preload("res://src/presentation/hero_cut_in.gd").play(app.layer,"warrior")
	check(cutin.has_node("ComicImpactPanel"),"foreground has slanted comic panel")
	check(Outline.is_baked(cutin.picture.texture) or cutin.picture.material is ShaderMaterial,"hero foreground shares white rim")
	cutin.queue_free();await process_frame
	var enemy = preload("res://src/presentation/enemy_cut_in.gd").play(app.layer,"goblin_0")
	check(enemy.has_node("ComicImpactPanel") and (Outline.is_baked(enemy.picture.texture) or enemy.picture.material is ShaderMaterial),"enemy foreground shares panel and rim")
	enemy.queue_free();await process_frame
	app.queue_free();await process_frame
	print("COMIC CUTOUTS: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
func render_probe() -> void:
	if DisplayServer.get_name()=="headless": return
	var viewport = SubViewport.new();viewport.size=Vector2i(128,128);viewport.transparent_bg=true
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(viewport)
	var pixels = Image.create(128,64,false,Image.FORMAT_RGBA8);pixels.fill(Color.TRANSPARENT)
	pixels.fill_rect(Rect2i(16,16,32,32),Color.RED)
	pixels.fill_rect(Rect2i(64,0,64,64),Color.GREEN)
	var sprite = Sprite2D.new();sprite.centered=false;sprite.texture=ImageTexture.create_from_image(pixels)
	sprite.hframes=2;sprite.scale=Vector2(2,2);viewport.add_child(sprite);Outline.attach_sprite(sprite)
	await RenderingServer.frame_post_draw
	var result = viewport.get_texture().get_image();var whites=0;var greens=0
	for y in range(128):
		for x in range(128):
			var pixel = result.get_pixel(x,y)
			if pixel.a>0.4 and pixel.r>0.8 and pixel.g>0.8 and pixel.b>0.7: whites+=1
			if pixel.a>0.4 and pixel.g>0.8 and pixel.r<0.2: greens+=1
	check(whites>100 and whites<1600,"native rim is visible and remains thin")
	check(greens==0,"neighboring atlas cell never leaks into outline")
	check(result.get_pixel(127,64).a<0.01,"opaque neighbor cannot create a false rim at the frame boundary")
	check(result.get_pixel(64,64).r>0.9 and result.get_pixel(64,64).g<0.1,"interior art colors are preserved")
	sprite.modulate.a=0.35;await RenderingServer.frame_post_draw
	result=viewport.get_texture().get_image()
	check(absf(result.get_pixel(64,64).a-0.35)<0.02,"modulate alpha is applied exactly once")
	viewport.queue_free();await process_frame
