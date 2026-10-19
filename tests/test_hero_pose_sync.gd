extends SceneTree
const Game = preload("res://src/game.gd")
const Playback = preload("res://src/presentation/hero_attack_playback.gd")
const CutIn = preload("res://src/presentation/hero_cut_in.gd")
var checks = 0
var failures = 0
var app: Control
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func exercise(hero: String, card_id: String, cutins: bool = true, speed: float = 1.0) -> void:
	app.game.new_run([hero, "mage" if hero != "mage" else "warrior"], 42)
	app.game.enter_node(0)
	app.game._start_combat(["skeleton", "skeleton_shielder"])
	for enemy in app.game.run.combat.enemies:
		enemy.hp = 1000; enemy.max_hp = 1000; enemy.block = 0
		enemy.intent = {"damage": 0, "block": 0, "target": 0}
	for unit in app.game.run.heroes: unit.block = 0
	app.game.run.combat.hand = [{"id": card_id, "upgraded": false}]
	app.game.run.combat.energy = 20
	app.game.profile.settings = {"reduce_cutins": not cutins, "combat_speed": speed}
	app.apply_options()
	app.continue_run()
	await process_frame
	var card: Dictionary = app.game.content.cards[card_id]
	var expected = "attack" if card.damage > 0 else "guard"
	var actor: Control = app.hero_art[0]
	var targets: Array = app.game.valid_targets(0)
	check(not targets.is_empty(), card_id + " has a valid target")
	if targets.is_empty(): return
	app.animate_combat_action(0, int(targets[0]))
	var committed = app.game.run.duplicate(true)
	var seen = {}
	var late_samples = 0
	var synchronized = true
	var idle_after = true
	var limit = Time.get_ticks_msec() + 15000
	while app.combat_busy and Time.get_ticks_msec() < limit:
		var foreground = app.layer.get_node_or_null("HeroCutIn")
		if foreground != null and not foreground.completed:
			seen[foreground.get_instance_id()] = true
			synchronized = synchronized and actor.current_action == expected
			if foreground.elapsed > foreground.duration * .70: late_samples += 1
		elif not seen.is_empty():
			idle_after = idle_after and actor.current_action == "idle"
		await process_frame
	check(not app.combat_busy, card_id + " playback completes")
	check(synchronized, card_id + " pose held throughout the actual foreground lifetime")
	check(idle_after, card_id + " no extra guard or delayed attack after foreground")
	check((late_samples > 0) == cutins, card_id + " observed late cut-in frames or respected disabled cut-ins")
	check(seen.size() == (int(card.get("hits", 1)) if cutins else 0), card_id + " one synchronized foreground per strike")
	check(app.game.run == committed, card_id + " presentation leaves committed rules unchanged")
func verify() -> void:
	app = load("res://main.tscn").instantiate()
	app.game = Game.new("user://hero-pose-sync.save", false)
	app.game.profile.tutorial_complete = true
	root.add_child(app)
	for pair in [["warrior", "warrior_slash", "warrior_guard"], ["guardian", "guardian_strike", "guardian_guard"], ["rogue", "rogue_cut", "rogue_dodge"], ["mage", "mage_shard", "mage_ward"]]:
		await exercise(pair[0], pair[1])
		await exercise(pair[0], pair[2])
	await exercise("guardian", "guardian_bash") # Attack + block must not replay guard.
	await exercise("mage", "mage_spark", true, 2.0) # Multi-hit at fast combat speed.
	await exercise("warrior", "warrior_cleave") # Area attack holds one pose/cut-in.
	await exercise("warrior", "warrior_slash", false)
	await exercise("guardian", "guardian_guard", false)
	app.game.profile.settings.reduce_cutins = false
	app.apply_options()
	var actor: Control = app.hero_art[0]
	var cut = CutIn.play(app.layer, "guardian")
	var revision: int = actor.begin_action("attack")
	Playback.hold_until_finished(actor, revision, cut)
	cut.queue_free()
	await process_frame
	check(actor.current_action == "idle", "early foreground removal releases the pose")
	cut = CutIn.play(app.layer, "guardian")
	revision = actor.begin_action("attack")
	Playback.hold_until_finished(actor, revision, cut)
	var newer: int = actor.begin_action("guard")
	cut.queue_free()
	await process_frame
	check(actor.current_action == "guard", "old foreground cannot reset a newer action")
	actor.finish_action(newer)
	app.queue_free()
	await process_frame
	print("HERO POSE SYNC: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
