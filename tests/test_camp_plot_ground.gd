extends SceneTree
const Game = preload("res://src/game.gd")
const IDS = ["market", "expeditions", "forge", "church"]
# Sample each plot itself, excluding the transition into the neighbouring ground.
const REGIONS = [Rect2i(96, 262, 326, 82), Rect2i(424, 470, 425, 125), Rect2i(45, 383, 370, 129), Rect2i(882, 428, 398, 152)]
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
	var native = DisplayServer.get_name() != "headless"
	var original: Image
	if native:
		for node in app.layer.get_children():
			if node is CanvasItem: node.visible = node.name == "DayCampBackground"
		await RenderingServer.frame_post_draw
		original = root.get_texture().get_image()
	for i in range(IDS.size()):
		# Purchase through the public API; returning to camp must reflect it.
		var bought: bool
		if IDS[i] == "market": bought = app.game.build_market()
		elif IDS[i] == "forge": bought = app.game.build_forge()
		else: bought = app.game.camp_action("build", {"id": IDS[i]})
		check(bought, "construction succeeds: " + IDS[i])
		app.open_base_camp()
		await create_timer(0.25).timeout
		var material = app.layer.get_node("DayCampBackground").material
		var flags: Vector4 = material.get_shader_parameter("built_plots")
		for j in range(IDS.size()): check(flags[j] == (1.0 if j <= i else 0.0), "only built lots use clean ground")
		if native:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("camp_plots/" + str(i) + "-" + IDS[i] + ".png"))
			# Isolate background for pixel checks: runtime building art must not mask faults.
			for node in app.layer.get_children():
				if node is CanvasItem: node.visible = node.name == "DayCampBackground"
			await RenderingServer.frame_post_draw
			var ground = root.get_texture().get_image()
			for j in range(i + 1, IDS.size()):
				check(ground.get_region(REGIONS[j]).get_data() == original.get_region(REGIONS[j]).get_data(), "unbuilt plot pixels preserved: " + IDS[j])
			check(ground.get_region(REGIONS[i]).get_data() != original.get_region(REGIONS[i]).get_data(), "built plot pixels replaced")
			if i == 3: ground.save_png(preload("res://tests/artifacts.gd").path("camp_plots/clean-ground.png"))
	print("CAMP PLOT GROUND: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
