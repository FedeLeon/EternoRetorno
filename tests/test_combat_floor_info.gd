extends SceneTree
const Game = preload("res://src/game.gd")
const Layout = preload("res://src/ui/components/combat_layout.gd")
var app: Control
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ", message)
func click(point: Vector2) -> void:
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT; event.pressed = pressed; event.position = point
		root.push_input(event)
	await process_frame
func capture(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat-floor/" + id + ".png"))
func run_tests() -> void:
	root.size = Vector2i(1280,720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-floor-info.save", false)
	app.game.profile.tutorial_complete = true
	root.add_child(app)
	for floor_number in [1,2,3]:
		for pair in [["warrior","guardian"],["rogue","mage"]]:
			app.game.new_run(pair, 0); app.game.enter_node(0)
			app.game.run.floor = floor_number
			app.game._start_combat(["skeleton", "skeleton_shielder", "skeleton_mage"])
			app.game.run.heroes[0].strength_pct = 25
			app.game.run.combat.enemies[0].poison = 3
			app.continue_run(); await process_frame
			var ground = Layout.ground_for(app)
			var hero_ground = Layout.hero_ground_for(app, ground)
			check(app.layer.find_children("EnemyName", "Label", true, false).is_empty(), "No enemy name plates")
			for i in range(2):
				var actor = app.hero_art[i]
				var bottom = preload("res://src/presentation/hero_grounding.gd").bottom(actor.sprite.sprite_frames.get_frame_texture("idle",0))
				var foot = actor.get_global_transform() * Vector2(0,actor.sprite.position.y + bottom*actor.sprite.scale.y)
				check(absf(foot.y-hero_ground)<1 and is_equal_approx(hero_ground-ground, 16), "Heroes share a ground line slightly below enemies")
				check(app.hero_health[i].global_position.y == Layout.TOP, "Hero health moved up")
				check(actor.scale.y * actor.get_meta("idle_height") > 210, "Heroes use the newly available height")
				var strip = actor.get_parent().get_node("HeroEffects")
				check(strip.global_position.y > hero_ground and strip.get_global_rect().end.y <= Layout.INFO_BOTTOM, "Hero effects below feet and clear of cards")
			for i in range(3):
				var intent = app.layer.get_node("EnemyIntent%d" % i)
				check(intent.global_position.y > ground and intent.get_global_rect().end.y <= Layout.INFO_BOTTOM, "Enemy intent below feet and clear of cards")
				check(app.enemy_health[i].global_position.y == Layout.TOP, "Enemy health moved up")
			var before = app.game.run.duplicate(true)
			var rng = app.game.rng.state
			await click(app.layer.get_node("EnemyTarget0").get_global_rect().get_center())
			check(is_instance_valid(app.overlay), "Click enemy opens inspection")
			var texts = app.overlay.find_children("*", "Label", true, false).map(func(label): return label.text)
			check(texts.has(app.game.content.enemies[app.game.run.combat.enemies[0].id].name), "Inspection shows enemy name")
			check(texts.any(func(text): return "PV" in text) and texts.any(func(text): return "Bloqueo activo:" in text), "Inspection shows life and block")
			var frame = app.overlay.get_node("InspectionFrame")
			check(frame.size.x <= 560 and frame.size.y <= 440, "Inspection stays compact")
			var rows = frame.get_node("InspectionRows").get_child(0)
			for row in rows.get_children():
				check(row.has_node("Icon") and row.get_node("Icon").texture != null, "Every inspection line has an icon")
			check(app.game.run == before and app.game.rng.state == rng, "Inspection is read only")
			await capture("floor%d-%s-inspect" % [floor_number,pair[0]])
			app.close_modal(); await process_frame
			await capture("floor%d-%s" % [floor_number,pair[0]])
			# Select a known owned attack, without changing targeting semantics.
			var attack_id = ""
			for id in app.game.content.cards:
				var card: Dictionary = app.game.content.cards[id]
				if card.owner == pair[0] and card.target == "enemy" and card.damage > 0:
					attack_id = id; break
			app.game.run.combat.hand = [{"id":attack_id,"upgraded":false}]
			app.game.run.combat.energy = 99
			app.select_card(0); await process_frame
			var selected = app.layer.get_node("CombatHand").get_child(0).get_child(0)
			check(selected.global_position.y > Layout.INFO_BOTTOM and selected.get_global_rect().end.y <= 720, "Raised card leaves floor information clear and stays inside viewport")
			await capture("floor%d-%s-selected" % [floor_number,pair[0]])
			var target: int = app.game.valid_targets(0)[0]
			var enemy_hp = app.game.run.combat.enemies[target].hp
			await click(app.layer.get_node("EnemyTarget%d" % target).get_global_rect().get_center())
			while app.combat_busy: await process_frame
			check(not is_instance_valid(app.overlay), "Selected attack never opens inspection")
			check(app.game.run.combat.enemies[target].hp < enemy_hp, "Selected attack still hits enemy")
	app.selected_card = -1
	app.game.run.combat.enemies[0].merge({"poison":8,"weak_pct":25,"fracture_pct":25,"root_hp":10,"enraged":true,"tainted":true,"risky":true,"modifier":"vampiric"},true)
	app.game.profile.settings = {"text_scale":1.12}
	app.apply_options(); app.render(); await process_frame
	await click(app.layer.get_node("EnemyTarget0").get_global_rect().get_center())
	var scroll = app.overlay.get_node("InspectionFrame/InspectionRows")
	check(app.overlay.get_node("InspectionFrame").size.y <= 440, "Many effects and large text keep compact frame")
	check(scroll.get_v_scroll_bar().max_value > scroll.get_v_scroll_bar().page, "Long effect list scrolls inside modal")
	var last = scroll.get_child(0).get_child(scroll.get_child(0).get_child_count()-1)
	scroll.ensure_control_visible(last); await process_frame; await process_frame
	check(last.get_global_rect().end.y <= scroll.get_global_rect().end.y + 1, "Last effect remains reachable")
	await capture("many-effects-inspect")
	app.back(); check(not is_instance_valid(app.overlay), "Back closes compact inspection")
	app.free()
	print("COMBAT FLOOR INFO: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
