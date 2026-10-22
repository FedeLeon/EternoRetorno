extends SceneTree
const Game = preload("res://src/game.gd")
const IDS = ["market", "expeditions", "forge", "church"]
const NODES = ["MarketBuilding", "ExpeditionsBuilding", "ForgeBuilding", "ChurchBuilding"]
var checks = 0
var failures = 0
func _initialize(): call_deferred("run_tests")
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func run_tests():
	root.size = Vector2i(1280, 720)
	var app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-plot-ground.save", false)
	root.add_child(app)
	app.open_base_camp()
	await process_frame
	check(app.layer.get_node("DayCampBackground").texture.resource_path.ends_with("dusk/background.png"), "dusk landscape is loaded")
	check(app.layer.has_node("RefugeBuilding") and not app.layer.has_node("ProjectsBuilding"), "refuge remains without removed projects")
	var fire = app.layer.get_node("DayCampfire")
	check(fire.embers_only and not fire.has_node("Flames") and fire.has_node("InteriorEmbers"), "camp uses interior light and sparks without flames")
	check(fire.position == Vector2(674, 409), "barrel base is centred on the illustrated camp circle")
	var barrel_transform = fire.barrel.transform
	await create_timer(0.3).timeout
	check(fire.barrel.transform == barrel_transform and fire.get_node("InteriorEmbers").elapsed > 0, "embers move while metal barrel stays still")
	await capture("unbuilt")
	for i in range(IDS.size()):
		var bought: bool
		if IDS[i] == "market": bought = app.game.build_market()
		elif IDS[i] == "forge": bought = app.game.build_forge()
		else: bought = app.game.camp_action("build", {"id":IDS[i]})
		check(bought, "construction succeeds: " + IDS[i])
		app.open_base_camp()
		await process_frame
		for j in range(IDS.size()):
			check(not app.layer.has_node("EmptyPlot%d" % j), "unbuilt lots show background without plot artwork")
			check(app.layer.has_node(NODES[j]) == (j <= i), "built artwork follows saved buildings")
		await capture(str(i) + "-" + IDS[i])
	for id in NODES + ["RefugeBuilding"]:
		var picture = app.layer.get_node(id)
		check(picture.flip_h == (id in ["MarketBuilding", "ForgeBuilding"]), "only market and forge face the camp centre: " + id)
		check(picture.texture is AtlasTexture, "building trims transparent canvas: " + id)
		check(picture.size.x >= 260, "building occupies its ground footprint: " + id)
		var opaque = picture.texture.get_image().get_used_rect()
		check(float(opaque.size.x) / picture.texture.get_width() > 0.97 and float(opaque.size.y) / picture.texture.get_height() > 0.97, "no unused image margins inside building slot: " + id)
	var entrances = ["Plot0", "Plot1", "Plot2", "Plot3", "CampTent", "CampExit"]
	check(app.layer.get_node("ChurchBuilding").get_rect().end.y == 599, "laboratory keeps lower-right ground position")
	for pair in [["Plot0", "MarketBuilding"], ["Plot2", "ForgeBuilding"]]:
		var entrance = app.layer.get_node(pair[0])
		check(entrance.artwork_flipped, "click mask follows mirrored artwork")
		var mask = entrance.alpha_mask
		for y in range(1,10):
			for x in range(1,10):
				var pixel = Vector2i(mask.get_size().x*x/10,mask.get_size().y*y/10)
				var point = entrance.artwork_rect.position + (Vector2(pixel)+Vector2(.5,.5))*entrance.pixel_scale
				if entrance.passthrough_areas.any(func(area):return area.has_point(point)): continue
				check(entrance._has_point(point) == mask.get_bitv(Vector2i(mask.get_size().x-1-pixel.x,pixel.y)), "mirrored silhouette remains clickable")
	for pair in [["Plot0", "MarketBuilding"], ["Plot3", "ChurchBuilding"]]:
		var caption: Rect2 = app.layer.get_node(pair[0]).get_meta("caption_rect")
		var picture: Control = app.layer.get_node(pair[1])
		check(caption.end.y <= picture.position.y, "market and laboratory captions sit above roofs")
		var entrance = app.layer.get_node(pair[0])
		check(entrance.artwork_rect.position.is_equal_approx(picture.position - entrance.position), "raised caption preserves artwork hit mask")
	for id in entrances:
		var area: Rect2 = app.layer.get_node(id).get_meta("caption_rect")
		check(Rect2(0,80,1280,640).encloses(area), "caption stays clear of header and viewport: " + id)
		for other in entrances:
			if id == other: continue
			check(not area.intersects(app.layer.get_node(other).get_meta("caption_rect")), "captions do not overlap")
		for other in entrances:
			if id == other: continue
			var neighbour = app.layer.get_node(other)
			if neighbour.has_method("configure"):
				check(not neighbour._has_point(area.get_center() - neighbour.position), "building does not intercept neighbouring caption: " + other + "/" + id)
		var button = app.layer.get_node(id)
		var local = area.get_center()-button.position
		check(button._has_point(local) if button.has_method("_has_point") else Rect2(Vector2.ZERO,button.size).has_point(local), "caption remains clickable: " + id)
	print("CAMP PLOT GROUND: %d checks / %d failures" % [checks, failures])
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)
func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("camp_dusk/" + file + ".png"))
