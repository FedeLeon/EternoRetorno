extends SceneTree
const Game = preload("res://src/game.gd")
const Reserve = preload("res://src/rules/card_reserve.gd")
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func fresh() -> RefCounted:
	var game = Game.new("user://reserve-test.save", false)
	game.new_run(["warrior", "guardian"], 91)
	game.enter_node(0)
	for enemy in game.run.combat.enemies:
		enemy.hp = 999
		enemy.max_hp = 999
		enemy.intent.damage = 0
	return game
func inventory(b: Dictionary) -> int:
	var total = 0
	for pile in ["draw", "hand", "discard", "inactive", "reserved"]: total += b.get(pile, []).size()
	return total
func _initialize() -> void:
	var g = fresh()
	var b: Dictionary = g.run.combat
	var count = inventory(b)
	var original = b.hand[0].duplicate(true)
	original.upgraded = true
	original.upgrade_variant = "custom_preserved_field"
	b.hand[0] = original
	b.energy = 0
	var random_state = g.rng.state
	check(not g.reserve_card(-1) and not g.reserve_card(99), "Invalid index rejects")
	check(g.reserve_card(0), "Reserve works with zero energy")
	check(b.energy == 0 and g.rng.state == random_state, "Reserve costs no energy and consumes no RNG")
	check(b.hand.size() == 5 and b.reserved == [original], "Exactly one instance leaves playable hand")
	check(not g.reserve_card(0) and b.reserve_used, "One reserve per turn")
	check(inventory(b) == count, "No card lost or duplicated")
	g.save_enabled = true
	g.checkpoint()
	var reloaded = Game.new("user://reserve-test.save")
	check(reloaded.run.combat.reserved == [original], "Reserved instance survives save/load")
	check(not reloaded.reserve_card(0), "Reload cannot reset one-per-turn limit")
	check(reloaded.end_turn(), "Turn resolves with reserved card")
	b = reloaded.run.combat
	check(b.reserved.is_empty() and not b.reserve_used, "New turn clears slot and renews reserve")
	check(b.hand.size() == 7 and b.hand[0] == original, "Saved instance returns ahead of six new cards")
	check(inventory(b) == count, "Full turn conserves all instances")
	check(reloaded.reserve_card(0), "Can reserve again on following turn")
	g = fresh()
	b = g.run.combat
	var dead_instance = b.hand[0].duplicate(true)
	check(g.reserve_card(0), "Reserve before owner falls")
	var owner = g.owner_index(dead_instance)
	g.run.heroes[owner].hp = 0
	g._remove_inactive()
	check(b.reserved.is_empty() and dead_instance in b.inactive, "Fallen owner's reserved card becomes inactive")
	g = fresh()
	b = g.run.combat
	b.erase("reserved")
	b.erase("reserve_used")
	check(g.reserve_card(0), "Old saves without reserve fields remain playable")
	g.run.phase = "reward"
	check(not g.reserve_card(0), "No reserve outside combat")
	g = fresh()
	var selected: Dictionary = g.run.combat.hand[0]
	g.run.heroes[g.owner_index(selected)].hp = 0
	check(not g.reserve_card(0), "Fallen owner cannot reserve")
	g = fresh()
	b = g.run.combat
	b.boss_objective = {"trapped":g.owner_index(b.hand[0])}
	check(not g.reserve_card(0), "Trapped hero cannot bypass the action restriction")
	g = fresh()
	b = g.run.combat
	b.hand = [{"id":"warrior_riposte","upgraded":false},{"id":"guardian_iron_chain","upgraded":false}]
	check(g.available_synergies().size() == 1, "Pair initially available")
	check(g.reserve_card(0) and g.available_synergies().is_empty(), "Face-down card cannot participate in a synergy")
	g = fresh()
	b = g.run.combat
	b.hand = [{"id":"warrior_slash","upgraded":false},{"id":"warrior_slash","upgraded":true}]
	g.reserve_card(1)
	check(b.hand[0].upgraded == false and b.reserved[0].upgraded, "Duplicate card IDs preserve the chosen instance")
	b.draw.clear()
	b.discard.clear()
	Reserve.restore(g)
	g._draw(6)
	check(b.hand.size() == 2 and b.hand[1].upgraded, "Empty piles never duplicate the retained card")
	g = fresh(); b = g.run.combat
	var hand_before: Array = b.hand.duplicate(true)
	var energy_before: int = b.energy
	var rng_before = g.rng.state
	check(not g.unreserve_card(), "No active reserve cannot be recovered")
	check(g.reserve_card(3) and b.reserved_index == 3, "Remember chosen position")
	check(g.unreserve_card() and b.hand == hand_before, "Undo restores exact hand order")
	check(b.energy == energy_before and g.rng.state == rng_before, "Undo costs no energy or RNG")
	check(g.reserve_card(1), "Can choose a different card after undo")
	g.save_enabled = true; g.checkpoint()
	reloaded = Game.new("user://reserve-test.save")
	check(reloaded.run.combat.reserved_index == 1 and reloaded.unreserve_card(), "Undo remains available after save/load")
	check(reloaded.run.combat.hand == hand_before, "Reload and undo preserve exact instances/order")
	g = fresh(); b = g.run.combat
	b.hand = [{"id":"warrior_slash","upgraded":false},{"id":"warrior_slash","upgraded":true},{"id":"guardian_guard","upgraded":false}]
	var retained = b.hand[1].duplicate(true)
	check(g.reserve_card(1), "Reserve upgraded duplicate in middle")
	check(g.play_card(0, g.valid_targets(0)[0]) and b.reserved_index == 0, "Playing earlier card keeps reserved position relative to remaining hand")
	check(g.unreserve_card() and b.hand[0] == retained, "Undo recovers correct upgraded duplicate after another play")
	g = fresh(); b = g.run.combat
	b.hand = [{"id":"warrior_riposte","upgraded":false},{"id":"guardian_iron_chain","upgraded":false},{"id":"warrior_slash","upgraded":true}]
	g.reserve_card(2)
	check(g.play_synergy(g.available_synergies()[0].id, 0) and b.reserved_index == 0, "Synergy keeps position as both earlier cards leave")
	check(g.unreserve_card() and b.hand.size() == 1 and b.hand[0].upgraded, "Synergy does not consume the reserved instance")
	g = fresh(); b = g.run.combat
	g.reserve_card(3)
	retained = b.reserved[0].duplicate(true)
	b.erase("reserved_index")
	check(g.unreserve_card() and b.hand[0] == retained and inventory(b) == 20, "Old active reserves without a position recover safely")
	print("CARD RESERVE: ", checks, " checks, ", failures, " failures")
	quit(1 if failures else 0)
