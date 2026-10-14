extends SceneTree
# Local visual gallery. Optional argument: warrior/guardian/rogue/mage.
var hero = "warrior"
func _initialize() -> void:
	if OS.get_cmdline_user_args().size() > 0: hero = OS.get_cmdline_user_args()[0]
	call_deferred("show_gallery")
func show_gallery() -> void:
	for weapon in range(4):
		for armor in range(4):
			if not ResourceLoader.exists("res://assets/forge/heroes/%s_w%d_a%d.png" % [hero, weapon, armor]):
				push_error("Import all 16 variants before reviewing " + hero)
				quit(1)
				return
	root.size = Vector2i(1280, 720)
	var background = ColorRect.new()
	background.color = Color("171a23")
	background.size = Vector2(1280, 720)
	root.add_child(background)
	for weapon in range(4):
		for armor in range(4):
			var actor = load("res://src/%s_sprite.gd" % hero).new()
			actor.position = Vector2(armor * 320 + 60, weapon * 180 + 2)
			actor.size = Vector2(192, 144)
			root.add_child(actor)
			preload("res://src/presentation/hero_equipment.gd").apply(actor, hero, {"weapon": weapon, "armor": armor})
			actor.sprite.pause()
			actor.sprite.frame = 0
			var label = Label.new()
			label.text = "%s · arma %d / armadura %d" % [hero, weapon, armor]
			label.position = Vector2(armor * 320 + 18, weapon * 180 + 150)
			label.add_theme_font_size_override("font_size", 16)
			root.add_child(label)
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("forge/" + hero + "-variants.png"))
	quit()
