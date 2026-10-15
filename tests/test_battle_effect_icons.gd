extends SceneTree
const Game = preload("res://src/game.gd")
const Snapshot = preload("res://src/ui/components/battle_effect_snapshot.gd")
const Strip = preload("res://src/ui/components/battle_effect_strip.gd")
const Indicator = preload("res://src/ui/components/block_indicator.gd")
var app: Control
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ", message)
func click(control: Control) -> void:
	var motion = InputEventMouseMotion.new()
	motion.position = control.get_global_rect().get_center()
	root.push_input(motion)
	await process_frame
	for pressed in [true, false]:
		var event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT; event.pressed = pressed
		event.position = control.get_global_rect().get_center()
		root.push_input(event)
	await process_frame
	await process_frame
func shot(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("battle_effects/" + id + ".png"))
func show(id: String) -> void:
	app.screen = "combat"; app.selected_card = -1; app.render()
	await process_frame; await process_frame
	for strip in app.layer.find_children("*", "", true, false).filter(func(n): return n is Strip):
		check(not strip.get_children().any(func(n): return n is ScrollContainer), "no hidden effects: " + id)
		for button in strip.find_children("Effect_*", "Button", true, false):
			check(strip.get_global_rect().encloses(button.get_global_rect()), "effect fits panel: " + id + "/" + button.name)
			for health in app.hero_health.values() + app.enemy_health.values():
				if is_instance_valid(health) and health.visible:
					check(not button.get_global_rect().intersects(health.get_global_rect()), "effect clear of life: " + id)
	await shot(id)
func ids(entries: Array) -> Array: return entries.map(func(e): return e.id)
func inspect_dialog(button: Button) -> void:
	var state = app.game.run.duplicate(true)
	var rng = app.game.rng.state
	await click(button)
	check(is_instance_valid(app.overlay), "real click opens dialog " + button.name)
	if not is_instance_valid(app.overlay): return
	var data: Dictionary = button.get_meta("battle_effect")
	var labels = app.overlay.find_children("*", "Label", true, false)
	check(labels.any(func(n): return n.text == data.title) and labels.any(func(n): return n.text == data.description), "specific explanation " + data.id)
	check(app.game.run == state and app.game.rng.state == rng, "inspection does not resolve or alter state " + data.id)
	var body: Label = labels.filter(func(n): return n.text == data.description)[0]
	var action: Button = app.overlay.find_children("*", "Button", true, false)[0]
	check(body.get_rect().end.y + 8 <= action.position.y, "dialog text clear of actions " + data.id)
	app.close_modal(); await process_frame
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://unused-battle-icons.save", false)
	app.game.profile.tutorial_complete = true
	root.add_child(app); await process_frame
	check(Snapshot.catalog.size() == 36, "complete 36-icon catalogue")
	for id in Snapshot.catalog:
		var image = load("res://assets/battle_effects/%s.png" % id).get_image()
		check(image.get_size() == Vector2i(128,128) and image.get_pixel(0,0).a == 0 and image.get_used_rect().size.x > 20, "transparent bounded asset " + id)
		check(not Snapshot.entry(id).description.is_empty(), "description " + id)
	var gallery = Control.new(); root.add_child(gallery); app.hide()
	var backdrop = ColorRect.new(); backdrop.color = Color("14121c"); backdrop.size = Vector2(1280,720); gallery.add_child(backdrop)
	var index = 0
	for id in Snapshot.catalog:
		var icon = TextureRect.new(); icon.texture = load("res://assets/battle_effects/%s.png" % id)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.position = Vector2(26 + index % 9 * 140, 20 + index / 9 * 173); icon.size = Vector2(100,100); gallery.add_child(icon)
		var caption = Label.new(); caption.text = Snapshot.catalog[id].title; caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; caption.add_theme_font_size_override("font_size",14)
		caption.position = icon.position + Vector2(-15,104); caption.size = Vector2(130,52); gallery.add_child(caption); index += 1
	await process_frame; await shot("catalogue"); gallery.free(); app.show()
	app.game.new_run(["guardian","rogue"],12,{},3); app.game.enter_node(0)
	var protector = app.game.content.enemies.keys().filter(func(id): return app.game.content.enemies[id].get("role","") == "protector")[0]
	var support = app.game.content.enemies.keys().filter(func(id): return app.game.content.enemies[id].get("role","") == "support")[0]
	app.game._start_combat(["skeleton", protector, support])
	var b = app.game.run.combat
	b.enemies[0].rear = true; b.enemies[0].root_hp = 7; b.enemies[0].modifier = "vampiric"
	b.enemies[0].intent = {"damage":9,"block":7,"target":0,"counter":4,"all":true,"special":"embers"}
	b.enemies[1].intent = {"damage":4,"block":7,"target":0,"special":"embers"}
	b.enemies[2].intent = {"damage":3,"block":0,"target":1,"coordination":"hunt"}
	app.game.run.heroes[0].strength_pct = 25; app.game.run.heroes[0].block = 3
	var original = app.game.run.duplicate(true); var rng = app.game.rng.state
	check(ids(Snapshot.enemy(app.game,0)).has("rear_guard") and ids(Snapshot.enemy(app.game,0)).has("roots"), "formation and roots exposed")
	check(app.game.run == original and app.game.rng.state == rng, "snapshot is read only")
	await show("triple-embers")
	for intent in app.layer.find_children("EnemyIntent*","",true,false):
		for indicator in intent.get_children().filter(func(n): return n is Indicator):
			check(indicator.position.x >= 0 and indicator.get_rect().end.x <= intent.size.x, "compact intention stays in actor column")
		for button in intent.find_children("Effect_*","Button",true,false):
			check(button.text.is_empty() and button.get_global_rect().position.y > 110 and button.get_global_rect().end.y <= preload("res://src/ui/components/combat_layout.gd").INFO_BOTTOM, "special icon below actor and clear of cards")
	check(not app.layer.find_children("*","Button",true,false).any(func(n): return "Brasas" in n.text or "Retaguardia" in n.text), "no tactical text signs")
	for button in app.layer.find_children("Effect_*","Button",true,false): await inspect_dialog(button)
	var ember_button = app.layer.get_node("EnemyIntent0/EnemyEffects/Effect_embers")
	await click(ember_button); await shot("embers-dialog"); app.close_modal(); await process_frame
	b.enemies[1].hp = 0
	check(not ids(Snapshot.enemy(app.game,0)).has("rear_guard"), "cover gone when last protector falls")
	check(Snapshot.enemy(app.game,1).is_empty(), "dead enemies have no effects")
	preload("res://src/rules/combat_depth.gd").interrupt(app.game,b.enemies[0])
	check(not ids(Snapshot.enemy(app.game,0)).has("embers"), "interruption removes advertised special")
	for special in ["resurrect","prison","armored_strike"]:
		b.enemies[0].intent.special = special; await show(special)
		var id: String = {"resurrect":"resurrection","prison":"imprisonment","armored_strike":"charged_strike"}[special]
		await inspect_dialog(app.layer.get_node("EnemyIntent0/EnemyEffects/Effect_"+id))
	for modifier in ["bulwark","frenzied"]:
		b.enemies[0].modifier = modifier
		check(ids(Snapshot.enemy(app.game,0)).has("frenzy" if modifier == "frenzied" else modifier), "elite effect " + modifier)
	b.enemies[0].enraged = true; b.enemies[0].risky = true; b.enemies[0].tainted = true; b.enemies[0].poison = 4
	b.enemies[0].weak_pct = 25; b.enemies[0].fracture_pct = 25; b.enemies[0].intent.coordination = "grief"
	await show("enemy-stacked")
	check(ids(Snapshot.enemy(app.game,0)).has("grief") and ids(Snapshot.enemy(app.game,0)).has("ambush"), "coordination and risk")
	app.game.run.curses = ["blood","burden","scar"]
	app.game.run.relics = ["storm_drum","fang","viper_tooth","drill_tusk","ivory_mirror","turtle_charm","dawn_bell","chalice"]
	app.game.run.heroes[0].turn_strength = 3; app.game.run.heroes[0].turn_magic = 2; app.game.run.heroes[0].poison = 2
	app.game.run.event_flags = {"pair_focus":true}
	b.prepared = [{"owner":0,"card":{"name":"Golpe reservado"},"turn":2,"targets":[0]}]
	await show("hero-stacked")
	var effects = Snapshot.hero(app.game,0)
	for id in ["prepared","strength","poison","weapon_boost","magic_boost","bond_focus","curse_blood","curse_burden","curse_scar","set_multi","set_poison","set_block","set_heal"]:
		check(id in ids(effects), "hero effect " + id)
	var hero_strip = app.layer.get_node("HeroTarget0/HeroEffects")
	check(not hero_strip.get_children().any(func(n): return n is ScrollContainer), "all effects visible without scrolling")
	for button in hero_strip.find_children("Effect_*", "Button", true, false):
		check(hero_strip.get_global_rect().encloses(button.get_global_rect()), "every effect fits its information block")
		check(not button.get_global_rect().intersects(app.hero_health[0].get_global_rect()), "effect does not overlap health")
		await inspect_dialog(button)
	app.game.profile.settings = {"text_scale":1.12}
	await show("large-text-effects")
	await click(app.layer.get_node("EnemyIntent0/EnemyEffects/Effect_weakness"))
	await shot("large-text-dialog"); app.close_modal(); await process_frame
	app.combat_busy = true
	await click(app.layer.get_node("EnemyIntent0/EnemyEffects/Effect_weakness"))
	check(not is_instance_valid(app.overlay), "inspection cannot interrupt action playback")
	app.combat_busy = false
	app.hero_health[0].set_health(1, app.game.run.heroes[0].max_hp)
	app.hero_health[0].animate_to(0); await app.hero_health[0].animation_finished
	check(not app.layer.get_node("HeroTarget0/HeroEffects").visible, "fallen hero hides effects during playback")
	for floor_number in [1,2,3]:
		app.game.new_run(["guardian","rogue"],12,{},floor_number)
		var boss = app.game.run.nodes.filter(func(n): return n.kind == "boss")[0]
		app.game.run.current = boss.id; app.game._start_combat(boss.encounter)
		var objective = app.game.run.combat.boss_objective
		if floor_number == 2: objective.trapped = 0
		await show("boss-%d" % floor_number)
		var button: Button = app.layer.find_children("Effect_*","Button",true,false).filter(func(n): return n.get_meta("battle_effect").get("objective_action",false))[0]
		var energy = app.game.run.combat.energy
		if floor_number == 1:
			app.game.run.combat.energy = 0
			await click(button)
			check(app.overlay.find_child("BossObjectiveAction",true,false).disabled, "objective action disabled with no energy")
			app.close_modal(); await process_frame
			app.game.run.combat.energy = energy
		await click(button); check(app.game.run.combat.energy == energy, "objective inspection spends no energy")
		check(is_instance_valid(app.overlay), "objective dialog opened by click")
		if not is_instance_valid(app.overlay):
			print("Unable to inspect objective: ", button.name, " ", button.get_global_rect(), " busy=", app.combat_busy)
			continue
		await shot("boss-dialog-%d" % floor_number)
		await click(app.overlay.find_child("BossObjectiveAction",true,false))
		check(app.game.run.combat.energy == energy - 1, "explicit action spends exactly one energy")
		check(objective.hp == 10 if floor_number == 1 else objective.trapped == -1 if floor_number == 2 else objective.hp == 1, "objective action preserved")
		await process_frame
		var enemy_intent = app.layer.get_node("EnemyIntent0")
		app.enemy_health[0].set_health(1, app.game.run.combat.enemies[0].max_hp)
		app.enemy_health[0].animate_to(0)
		await app.enemy_health[0].animation_finished
		check(not enemy_intent.visible, "fallen enemy hides its intentions and effects")
	app.queue_free(); await process_frame
	print("BATTLE EFFECT ICONS: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
