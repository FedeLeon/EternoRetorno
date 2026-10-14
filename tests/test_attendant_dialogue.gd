extends SceneTree
const Game = preload("res://src/game.gd")
var app: Control
var checks = 0
var failures = 0
func _initialize(): call_deferred("run_tests")
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func shot(id: String):
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("attendants/" + id + ".png"))
func run_tests():
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-attendants.save", false)
	root.add_child(app)
	for id in ["market", "forge", "church", "expeditions"]: app.game.profile.buildings[id] = true
	var profile = app.game.profile.duplicate(true)
	for id in ["market", "forge", "church", "expeditions"]:
		app.screen = id
		app.render()
		await process_frame
		var bubble = app.layer.get_node("AttendantDialogue")
		bubble.set_process(false)
		check(bubble.phrases.size() >= 5, "varied phrases: " + id)
		check(bubble.modulate.a == 0.0, "initial silence: " + id)
		bubble._process(1.1)
		bubble._process(0.5)
		check(bubble.speaking and bubble.modulate.a == 1.0, "bubble fades in: " + id)
		check(bubble.mouse_filter == Control.MOUSE_FILTER_IGNORE and bubble.find_children("*", "Control", true, false).all(func(c): return c.mouse_filter == Control.MOUSE_FILTER_IGNORE), "bubble does not block clicks")
		var first = bubble.text_label.text
		await shot(id)
		bubble._process(bubble.duration)
		check(not bubble.speaking and bubble.modulate.a == 0.0, "bubble closes: " + id)
		bubble._process(bubble.duration)
		bubble._process(0.5)
		check(bubble.speaking and bubble.text_label.text != first, "next phrase differs: " + id)
		check(app.game.profile == profile, "dialogue never mutates profile")
		for phrase in bubble.phrases:
			bubble.text_label.text = phrase
			await process_frame
			check(bubble.text_label.get_rect().end.y <= bubble.size.y - 10, "phrase fits bubble: " + id)
	app.screen = "church"
	for hero in app.game.content.heroes:
		app.church_hero = hero
		app.render()
		await process_frame
		var bubble = app.layer.get_node("AttendantDialogue")
		bubble.set_process(false)
		bubble._process(1.1)
		bubble._process(0.5)
		for card in app.layer.find_children("Specialization_*", "Control", false, false):
			check(card.position.x >= 510, "specializations leave attendant visible")
			var labels = card.find_children("*", "Label", false, false)
			for n in range(labels.size() - 1):
				check(labels[n].get_rect().end.y <= labels[n + 1].position.y, "specialization labels do not overlap: " + hero)
			check(labels[-1].get_rect().end.y < card.get_node("LearnSpecialization").position.y, "status leaves button clear")
		if hero == "guardian": await shot("church-specializations")
	# All 30 contracts must fit, including the longest descriptions.
	var contracts = preload("res://src/rules/expeditions.gd").catalog()
	for contract in contracts:
		var id: String = contract.id
		app.game.profile.expeditions.offers = [id]
		app.screen = "expeditions"
		app.render()
		await process_frame
		var card = app.layer.get_node("Contract_" + id)
		check(card.position.x >= 510, "contracts leave attendant visible")
		var labels = card.find_children("*", "Label", false, false)
		for n in range(labels.size() - 1):
			check(labels[n].get_rect().end.y <= labels[n + 1].position.y, "contract labels do not overlap: " + id)
	app.open_base_camp()
	await process_frame
	check(not app.layer.has_node("AttendantDialogue"), "dialogue removed when leaving building")
	print("ATTENDANTS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
