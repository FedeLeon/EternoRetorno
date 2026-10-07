class_name ERGame
extends RefCounted
# Transient receipt for presentation; never persisted or used to calculate damage.
var resolved_enemy_attacks: Array[int] = []
var resolved_enemy_blocks: Dictionary = {}
var resolved_hero_defenses: Dictionary = {}
var resolved_hero_blocks: Dictionary = {}
var resolved_card_hits: Array = []

const Achievements = preload("res://src/rules/achievements.gd")
const Synergies = preload("res://src/rules/card_synergies.gd")
const Progression = preload("res://src/rules/camp_progression.gd")
const CampExpansion = preload("res://src/rules/camp_expansion.gd")
const Expeditions = preload("res://src/rules/expeditions.gd")
const Specializations = preload("res://src/rules/specializations.gd")
const Forge = preload("res://src/rules/forge_progression.gd")
const Treasure = preload("res://src/rules/treasure.gd")
const RunRelics = preload("res://src/rules/run_relics.gd")
const Modifiers = preload("res://src/rules/combat_modifiers.gd")
const Content = preload("res://src/content.gd")
const Dungeon = preload("res://src/dungeon.gd")
const SaveStore = preload("res://src/save_store.gd")
var content = Content.new()
var store: RefCounted
var rng = RandomNumberGenerator.new()
var resolved_prepared_hits: Array = []
var profile: Dictionary = {"unlocked_cards": [], "unlocked_relics": [], "history": [], "victories": 0, "attempts": 0}
var run: Dictionary = {}
var save_enabled = true
var message = ""

func _init(save_path: String = "user://eterno.save", persist: bool = true) -> void:
	save_enabled = persist
	store = SaveStore.new(save_path)
	if persist:
		var saved = store.read()
		if not saved.is_empty():
			profile = saved.profile
			run = saved.run
			if not run.is_empty():
				rng.state = run.rng_state
		message = store.last_error

	var migrated = Progression.migrate(profile)
	var forge_migrated = Forge.migrate(profile)
	var expansion_migrated = CampExpansion.migrate(profile)
	var achievements_migrated = Achievements.sync(profile, run)
	if forge_migrated or expansion_migrated or migrated or achievements_migrated:
		checkpoint()

func camp_action(action: String, payload: Dictionary) -> bool:
	if not CampExpansion.transact(profile, run, action, payload): return false
	checkpoint()
	return true

func configure_starter(hero: String, attacks: int) -> bool:
	if not preload("res://src/rules/starter_decks.gd").configure(content, profile, hero, attacks): return false
	checkpoint()
	return true

func build_forge() -> bool:
	if not Forge.build(profile):
		return false
	checkpoint()
	return true

func buy_forge_upgrade(hero: String, track: String, expected_level: int) -> bool:
	if not Forge.buy(profile, hero, track, expected_level):
		return false
	checkpoint()
	return true

func build_market() -> bool:
	if not Progression.build(profile): return false
	checkpoint()
	return true

func buy_market_card(id: String) -> bool:
	if not Progression.buy(profile, content.cards, id): return false
	checkpoint()
	return true

func checkpoint() -> void:
	Achievements.sync(profile, run)
	if not run.is_empty():
		run.rng_state = rng.state
	if save_enabled and not store.write(profile, run):
		message = store.last_error

func new_run(party: Array, seed_value: int = -1, equipment: Dictionary = {}, starting_floor: int = 1) -> bool:
	var accepted: bool = preload("res://src/rules/run_lifecycle.gd").start(self, party, seed_value, equipment, starting_floor)
	if accepted: checkpoint()
	return accepted

func available_nodes() -> Array:
	if run.is_empty() or run.phase != "map" or run.boss_defeated:
		return []
	return [0] if run.current == -1 else run.nodes[run.current].next

func enter_node(index: int) -> bool:
	if index not in available_nodes():
		return false
	run.current = index
	run.visited.append(index)
	var node = run.nodes[index]
	if node.kind in ["combat", "elite", "boss"]:
		_start_combat(node.encounter)
	else:
		run.phase = "room"
		run.room_note = ""
		if node.kind == "event" and node.event == "wandering_merchant":
			run.phase = "merchant"
			preload("res://src/rules/travel_encounters.gd").prepare(self)
		preload("res://src/rules/travel_encounters.gd").apply_room(self, node.kind)
		if node.kind == "treasure":
			run.treasure = Treasure.prepare(rng, content.items.keys())
	checkpoint()
	return true

func living_heroes() -> Array:
	var result: Array = []
	for i in range(run.heroes.size()):
		if run.heroes[i].hp > 0:
			result.append(i)
	return result

func owner_index(card_instance: Dictionary) -> int:
	return run.party.find(content.cards[card_instance.id].owner)

func _shuffle(array: Array) -> void:
	for i in range(array.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp

func _start_combat(encounter: Array) -> void:
	run.phase = "combat"
	for hero in run.heroes: Modifiers.clear(hero)
	run.reward_relic = ""
	var enemies: Array = []
	for id in encounter:
		var def = content.enemies[id]
		enemies.append({"id": id, "hp": int(def.hp), "max_hp": int(def.hp), "block": 0, "poison": 0, "intent": {}})
	preload("res://src/rules/adventure_extensions.gd").strengthen(run, enemies, content)
	run.combat = {"enemies": enemies, "draw": run.deck.duplicate(true), "hand": [], "discard": [], "inactive": [], "energy": 0, "turn": 0}
	run.combat.hero_fell = false
	run.log = ["El silencio se rompe."]
	preload("res://src/rules/combat_depth.gd").initialize(self)
	_shuffle(run.combat.draw)
	_start_turn()
	if "ember" in run.relics:
		for h in run.heroes:
			h.block += 4

func _start_turn() -> void:
	preload("res://src/rules/combat_turns.gd").start(self)

func _draw(count: int) -> void:
	var b = run.combat
	while count > 0:
		if b.draw.is_empty():
			if b.discard.is_empty():
				break
			b.draw = b.discard.duplicate(true)
			b.discard.clear()
			_shuffle(b.draw)
		var instance = b.draw.pop_back()
		if run.heroes[owner_index(instance)].hp <= 0:
			b.inactive.append(instance)
			continue
		b.hand.append(instance)
		count -= 1

func valid_targets(hand_index: int) -> Array:
	if run.is_empty() or run.phase != "combat" or hand_index < 0 or hand_index >= run.combat.hand.size():
		return []
	var instance = run.combat.hand[hand_index]
	var c = effective_card(instance)
	var owner = owner_index(instance)
	if run.heroes[owner].hp <= 0 or c.cost > run.combat.energy:
		return []
	if c.target in ["self", "all_allies"]:
		return [owner] # Confirm self/party effects on the owner; offensive area cards use enemies.
	if c.target == "ally":
		return living_heroes()
	var targets: Array = []
	for i in range(run.combat.enemies.size()):
		if run.combat.enemies[i].hp > 0:
			targets.append(i)
	return preload("res://src/rules/combat_depth.gd").targets(self, c, targets)

func available_synergies() -> Array:
	var combos = Synergies.available(run, content.synergies)
	for combo in combos:
		var poison_bonus = 0
		for hero in run.heroes:
			combo.damage += attack_bonus(hero, hero.id)
			poison_bonus = maxi(poison_bonus, relic_bonus(hero, "poison"))
		if combo.poison > 0: combo.poison += poison_bonus
		if "fang" in run.relics: combo.damage += 1
		# Each participant empowers their half of the combined strike.
		var bond = run.get("bond_variant", "balanced")
		if bond == "aggressive": combo.damage += 4; combo.block = maxi(0, int(combo.block) - 3)
		if bond == "protective": combo.damage = maxi(0, int(combo.damage) - 4); combo.block += 4
		var base_damage = int(combo.damage)
		var first_share = base_damage / 2
		combo.damage = Modifiers.damage(first_share, run.heroes[0]) + Modifiers.damage(base_damage - first_share, run.heroes[1])
	return combos

func synergy_targets(id: String) -> Array:
	for combo in available_synergies():
		if combo.id == id and run.combat.energy >= combo.cost:
			var targets: Array = []
			for i in range(run.combat.enemies.size()):
				if run.combat.enemies[i].hp > 0: targets.append(i)
			return targets
	return []

func play_synergy(id: String, target: int) -> bool:
	resolved_card_hits.clear()
	if target not in synergy_targets(id): return false
	var combo: Dictionary = {}
	for candidate in available_synergies():
		if candidate.id == id: combo = candidate
	var b = run.combat
	b.energy -= int(combo.cost)
	# Descending indices preserve both exact instances, including upgrades.
	var indices: Array = combo.indices.duplicate()
	indices.sort()
	indices.reverse()
	for index in indices:
		b.discard.append(b.hand[index])
		b.hand.remove_at(index)
	if not preload("res://src/rules/combat_depth.gd").root_hit(self, b.enemies[target], int(combo.damage)):
		_damage(b.enemies[target], int(combo.damage), combo.pierce)
	if b.enemies[target].hp > 0 and int(b.enemies[target].intent.get("counter", 0)) > 0:
		var attacker = run.party.find(combo.heroes[0])
		_damage(run.heroes[attacker], 4)
		resolved_card_hits.append({"kind":"counter", "enemy":target, "owner":attacker, "hp":run.heroes[attacker].hp, "block":run.heroes[attacker].block, "damage":4})
	b.enemies[target].poison += int(combo.poison)
	for hero in run.heroes:
		if hero.hp <= 0: continue
		hero.block += int(combo.block)
		hero.hp = mini(hero.max_hp, hero.hp + int(combo.heal))
	_log("Sinergia: %s." % combo.name)
	_check_combat_end()
	checkpoint()
	return true

func play_card(hand_index: int, target: int) -> bool:
	var accepted: bool = preload("res://src/rules/card_actions.gd").play(self, hand_index, target)
	if accepted: checkpoint()
	return accepted

func _damage(unit: Dictionary, amount: int, pierce: bool = false) -> void:
	if unit.has("equipped_relic"):
		amount = maxi(0, amount - relic_bonus(unit, "armor"))
	var was_alive = unit.hp > 0
	var hp_before: int = unit.hp
	var absorbed = 0 if pierce else mini(unit.block, amount)
	unit.block -= absorbed
	unit.hp = maxi(0, unit.hp - (amount - absorbed))
	if run.get("phase", "") == "combat": preload("res://src/rules/combat_depth.gd").record(self, unit, amount, absorbed, hp_before - unit.hp)
	if unit.has("equipped_relic"):
		preload("res://src/rules/adventure_extensions.gd").statistic(run, "damage_taken", hp_before - unit.hp)
	if was_alive and unit.hp == 0 and relic_bonus(unit, "phoenix") > 0 and not unit.get("phoenix_used", false):
		unit.hp = 1
		unit.phoenix_used = true
		_log("El Ídolo del Fénix evita un golpe fatal.")
	if was_alive and unit.hp == 0 and unit.has("equipped_relic") and run.phase == "combat":
		run.combat.hero_fell = true
		preload("res://src/rules/adventure_extensions.gd").statistic(run, "fallen")

func end_turn() -> bool:
	var accepted: bool = preload("res://src/rules/combat_turns.gd").end(self)
	if accepted: checkpoint()
	return accepted

func _remove_inactive() -> void:
	var b = run.combat
	for pile in ["draw", "hand", "discard"]:
		for i in range(b[pile].size() - 1, -1, -1):
			if run.heroes[owner_index(b[pile][i])].hp <= 0:
				b.inactive.append(b[pile][i])
				b[pile].remove_at(i)

func _check_combat_end() -> bool:
	return preload("res://src/rules/combat_rewards.gd").check_end(self)

func _make_reward() -> void:
	preload("res://src/rules/combat_rewards.gd").make(self)

func choose_reward(index: int) -> bool:
	var accepted: bool = preload("res://src/rules/combat_rewards.gd").choose(self, index)
	if accepted: checkpoint()
	return accepted

func _roll_relic() -> String:
	return RunRelics.roll(run, profile, content.relics, rng)

func take_treasure() -> bool:
	if not _room_is("treasure") or not Treasure.open(run):
		return false
	Expeditions.add(run, "treasures")
	checkpoint()
	return true

func leave_treasure() -> bool:
	if not _room_is("treasure") or not Treasure.state(run.treasure).get("opened", false):
		return false
	run.phase = "map"
	checkpoint()
	return true

func _room_is(kind: String) -> bool:
	return not run.is_empty() and run.phase == "room" and run.nodes[run.current].kind == kind

func rest(heal: bool, card_index: int = -1, variant: String = "power") -> bool:
	if not _room_is("rest"):
		return false
	if heal:
		var extra = preload("res://src/rules/travel_encounters.gd").rest_bonus(self)
		for h in run.heroes:
			h.hp = mini(h.max_hp, h.hp + int(ceil(h.max_hp * 0.3)) + extra)
	else:
		if card_index < 0 or card_index >= run.deck.size() or run.deck[card_index].upgraded:
			return false
		var choices = preload("res://src/rules/card_upgrades.gd").choices(content.cards[run.deck[card_index].id])
		if not choices.any(func(choice): return choice.id == variant): return false
		run.deck[card_index].upgraded = true
		run.deck[card_index].upgrade_variant = variant
		Expeditions.add(run, "upgrades")
	run.phase = "map"
	checkpoint()
	return true

func choose_event(index: int) -> bool:
	if run.get("phase", "") == "merchant" and index == 1: return merchant_action("leave")
	if not _room_is("event") or index not in [0, 1]:
		return false
	var event_id = run.nodes[run.current].event
	if event_id not in ["well", "altar", "library"]:
		var applied = preload("res://src/rules/expanded_events.gd").choose(self, event_id, index)
		if applied:
			if index == 0: preload("res://src/rules/travel_encounters.gd").chain(self, event_id)
			checkpoint()
		return applied
	if index == 0:
		match event_id:
			"well":
				for h in run.heroes:
					h.hp = mini(h.max_hp, h.hp + 8)
			"altar":
				for h in run.heroes:
					if h.hp <= 5:
						return false
				var candidates: Array = []
				for i in range(run.deck.size()):
					if not run.deck[i].upgraded:
						candidates.append(i)
				if candidates.is_empty():
					return false
				for h in run.heroes:
					h.hp -= 5
				run.deck[candidates[rng.randi_range(0, candidates.size() - 1)]].upgraded = true
			"library":
				preload("res://src/rules/travel_encounters.gd").chain(self, event_id)
				_make_reward()
				checkpoint()
				return true
	run.phase = "map"
	checkpoint()
	return true

func descend() -> bool:
	if run.is_empty() or run.phase != "map" or not run.boss_defeated:
		return false
	if int(run.get("floor", 1)) < int(run.get("floor_count", 1)):
		preload("res://src/rules/dungeon_progression.gd").advance(run, rng)
	else:
		_finish(true)
	checkpoint()
	return true

func end_adventure() -> bool:
	if run.is_empty() or run.phase in ["victory", "defeat"]:
		return false
	run.abandoned = true
	_finish(false)
	checkpoint()
	return true

func _finish(won: bool) -> void:
	preload("res://src/rules/run_lifecycle.gd").finish(self, won)

func _log(line: String) -> void:
	if run.get("phase", "") == "combat":
		run.combat.get_or_add("journal", []).append(line)
		if run.combat.journal.size() > 200: run.combat.journal.pop_front()
	run.log.append(line)
	if run.log.size() > 5:
		run.log.pop_front()

func valid_equipment(party: Array, equipment: Dictionary) -> bool:
	if equipment.size() > 1:
		return false
	var used: Array = []
	for hero_id in equipment:
		var id = equipment[hero_id]
		if (hero_id != "team" and hero_id not in party) or not content.equipment.has(id) or id in used:
			return false
		used.append(id)
	return true

func relic_bonus(hero: Dictionary, effect: String) -> int:
	var relic = content.equipment.get(hero.get("equipped_relic", ""), {})
	return int(relic.get("value", 0)) if relic.get("effect", "") == effect else 0

func turn_energy() -> int:
	var amount = 3
	if run.combat.turn == 1:
		amount += 1 if "hourglass" in run.relics else 0
		for hero in run.heroes:
			if hero.hp > 0:
				amount += relic_bonus(hero, "energy")
				if run.get("team_relic", "") != "":
					break
	return amount

func attack_bonus(hero: Dictionary, owner: String) -> int:
	var bonus = int(hero.get("turn_strength", 0)) + int(hero.get("forge", {}).get("strength", 0))
	if run.get("team_relic", "") != "" or owner in ["mage", "cleric"]:
		bonus += relic_bonus(hero, "magic")
	if owner in ["mage", "cleric"]:
		bonus += int(hero.get("turn_magic", 0))
	return bonus

func effective_card(instance: Dictionary) -> Dictionary:
	var c = content.card(instance)
	if run.is_empty() or c.owner not in run.party:
		return c
	var hero = run.heroes[run.party.find(c.owner)]
	if c.damage > 0:
		c.damage += attack_bonus(hero, c.owner)
	if c.block > 0:
		c.block += int(hero.get("forge", {}).get("block", 0))
	if c.poison > 0:
		c.poison += relic_bonus(hero, "poison")
	Specializations.apply(c, hero, int(run.get("combat", {}).get("turn", 0)))
	RunRelics.apply(c, instance, hero, run, content.relics)
	if c.damage > 0: c.damage = Modifiers.damage(int(c.damage), hero)
	return c

func item_targets(id: String) -> Array:
	return preload("res://src/rules/items.gd").targets(self, id)

func use_item(id: String, target: int) -> bool:
	if not preload("res://src/rules/items.gd").apply(self, id, target):
		return false
	checkpoint()
	return true

func modify_event_card(index: int) -> bool:
	if not preload("res://src/rules/expanded_events.gd").modify(self, index): return false
	checkpoint()
	return true

func configure_bond(party: Array, variant: String) -> bool:
	if variant not in ["balanced", "aggressive", "protective"] or party.size() != 2: return false
	var key = preload("res://src/rules/adventure_extensions.gd").pair_key(party)
	if int(profile.get("bonds", {}).get(key, 0)) < 1: return false
	if not profile.has("bond_variants"): profile.bond_variants = {}
	profile.bond_variants[key] = variant
	checkpoint()
	return true

func merchant_action(action: String, index: int = -1) -> bool:
	if not preload("res://src/rules/travel_encounters.gd").transact(self, action, index): return false
	checkpoint()
	return true
