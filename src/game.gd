class_name ERGame
extends RefCounted

const Synergies = preload("res://src/rules/card_synergies.gd")
const Progression = preload("res://src/rules/camp_progression.gd")
const Treasure = preload("res://src/rules/treasure.gd")
const Content = preload("res://src/content.gd")
const Dungeon = preload("res://src/dungeon.gd")
const SaveStore = preload("res://src/save_store.gd")
var content = Content.new()
var store: RefCounted
var rng = RandomNumberGenerator.new()
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

	if Progression.migrate(profile):
		checkpoint()

func build_market() -> bool:
	if not Progression.build(profile): return false
	checkpoint()
	return true

func buy_market_card(id: String) -> bool:
	if not Progression.buy(profile, content.cards, id): return false
	checkpoint()
	return true

func checkpoint() -> void:
	if not run.is_empty():
		run.rng_state = rng.state
	if save_enabled and not store.write(profile, run):
		message = store.last_error

func new_run(party: Array, seed_value: int = -1, equipment: Dictionary = {}) -> bool:
	if party.size() != 2 or party[0] == party[1]:
		return false
	for id in party:
		if not content.heroes.has(id):
			return false
	if not valid_equipment(party, equipment):
		return false
	if seed_value == -1:
		rng.randomize()
	else:
		rng.seed = seed_value
	var initial_seed = rng.seed
	run = {"seed": initial_seed, "rng_state": rng.state, "phase": "map", "party": party.duplicate(), "heroes": [], "deck": [], "nodes": Dungeon.create(rng), "current": -1, "visited": [], "relics": [], "combat": {}, "reward": [], "boss_defeated": false, "log": [], "new_unlocks": []}
	run.team_relic = equipment.get("team", "")
	run.inventory = {}
	for id in party:
		run.heroes.append({"id": id, "hp": int(content.heroes[id].hp), "max_hp": int(content.heroes[id].hp), "block": 0})
		var hero = run.heroes.back()
		hero.equipped_relic = equipment.get("team", equipment.get(id, ""))
		hero.phoenix_used = false
		if relic_bonus(hero, "max_hp") > 0:
			hero.max_hp += relic_bonus(hero, "max_hp")
			hero.hp = hero.max_hp
		for card_id in content.heroes[id].starter:
			run.deck.append({"id": card_id, "upgraded": false})
	profile.erase("preparation")
	profile.attempts += 1
	message = ""
	checkpoint()
	return true

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
	var enemies: Array = []
	for id in encounter:
		var def = content.enemies[id]
		enemies.append({"id": id, "hp": int(def.hp), "max_hp": int(def.hp), "block": 0, "poison": 0, "intent": {}})
	run.combat = {"enemies": enemies, "draw": run.deck.duplicate(true), "hand": [], "discard": [], "inactive": [], "energy": 0, "turn": 0}
	run.log = ["El silencio se rompe."]
	_shuffle(run.combat.draw)
	_start_turn()
	if "ember" in run.relics:
		for h in run.heroes:
			h.block += 4

func _start_turn() -> void:
	var battle = run.combat
	battle.turn += 1
	battle.energy = turn_energy()
	for h in run.heroes:
		h.block = relic_bonus(h, "block") if h.hp > 0 else 0
		h.turn_strength = 0
		h.turn_magic = 0
	for enemy in battle.enemies:
		if enemy.hp <= 0:
			continue
		var pattern = content.enemies[enemy.id].pattern
		var intent = pattern[(battle.turn - 1) % pattern.size()].duplicate(true)
		var living = living_heroes()
		intent.target = living[rng.randi_range(0, living.size() - 1)]
		enemy.intent = intent
	_draw(6)

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
	if c.target in ["self", "all_allies", "all_enemies"]:
		return [owner] # Explicit confirmation on owner for area/self cards.
	if c.target == "ally":
		return living_heroes()
	var targets: Array = []
	for i in range(run.combat.enemies.size()):
		if run.combat.enemies[i].hp > 0:
			targets.append(i)
	return targets

func available_synergies() -> Array:
	var combos = Synergies.available(run, content.synergies)
	for combo in combos:
		var poison_bonus = 0
		for hero in run.heroes:
			combo.damage += attack_bonus(hero, hero.id)
			poison_bonus = maxi(poison_bonus, relic_bonus(hero, "poison"))
		if combo.poison > 0: combo.poison += poison_bonus
		if "fang" in run.relics: combo.damage += 1
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
	_damage(b.enemies[target], int(combo.damage), combo.pierce)
	b.enemies[target].poison += int(combo.poison)
	for hero in run.heroes:
		hero.block += int(combo.block)
		hero.hp = mini(hero.max_hp, hero.hp + int(combo.heal))
	_log("Sinergia: %s." % combo.name)
	_check_combat_end()
	checkpoint()
	return true

func play_card(hand_index: int, target: int) -> bool:
	if target not in valid_targets(hand_index):
		return false
	var b = run.combat
	var instance = b.hand[hand_index]
	var c = effective_card(instance)
	var owner = owner_index(instance)
	b.energy -= int(c.cost)
	b.hand.remove_at(hand_index)
	b.discard.append(instance)
	var enemy_targets: Array = []
	var ally_targets: Array = []
	match c.target:
		"enemy":
			enemy_targets = [target]
			ally_targets = [owner]
		"all_enemies":
			for i in range(b.enemies.size()):
				if b.enemies[i].hp > 0:
					enemy_targets.append(i)
		"ally": ally_targets = [target]
		"all_allies": ally_targets = living_heroes()
		"self": ally_targets = [owner]
	for i in enemy_targets:
		var enemy = b.enemies[i]
		for hit in range(int(c.hits)):
			if c.damage > 0:
				_damage(enemy, int(c.damage) + (1 if "fang" in run.relics else 0), c.pierce)
		enemy.poison += int(c.poison)
	for i in ally_targets:
		var hero = run.heroes[i]
		hero.block += int(c.block)
		hero.hp = mini(hero.max_hp, hero.hp + int(c.heal))
	_log("%s: %s." % [content.heroes[run.party[owner]].name, c.name])
	_check_combat_end()
	checkpoint()
	return true

func _damage(unit: Dictionary, amount: int, pierce: bool = false) -> void:
	if unit.has("equipped_relic"):
		amount = maxi(0, amount - relic_bonus(unit, "armor"))
	var was_alive = unit.hp > 0
	var absorbed = 0 if pierce else mini(unit.block, amount)
	unit.block -= absorbed
	unit.hp = maxi(0, unit.hp - (amount - absorbed))
	if was_alive and unit.hp == 0 and relic_bonus(unit, "phoenix") > 0 and not unit.get("phoenix_used", false):
		unit.hp = 1
		unit.phoenix_used = true
		_log("El Ídolo del Fénix evita un golpe fatal.")

func end_turn() -> bool:
	if run.is_empty() or run.phase != "combat":
		return false
	var b = run.combat
	b.discard.append_array(b.hand)
	b.hand.clear()
	# Poison ticks simultaneously before enemy actions, bypassing block.
	for enemy in b.enemies:
		if enemy.hp > 0 and enemy.poison > 0:
			_damage(enemy, enemy.poison, true)
			enemy.poison = maxi(0, enemy.poison - 1)
	if _check_combat_end():
		checkpoint()
		return true
	for enemy in b.enemies:
		if enemy.hp <= 0:
			continue
		enemy.block = 0
		var intent = enemy.intent
		enemy.block += int(intent.get("block", 0))
		var targets = living_heroes() if intent.get("all", false) else [intent.target]
		if not intent.get("all", false) and run.heroes[targets[0]].hp <= 0:
			targets = [living_heroes()[0]]
		for i in targets:
			_damage(run.heroes[i], int(intent.damage))
		_log("%s ataca por %d." % [content.enemies[enemy.id].name, intent.damage])
		if living_heroes().is_empty():
			_finish(false)
			checkpoint()
			return true
	_remove_inactive()
	_start_turn()
	checkpoint()
	return true

func _remove_inactive() -> void:
	var b = run.combat
	for pile in ["draw", "hand", "discard"]:
		for i in range(b[pile].size() - 1, -1, -1):
			if run.heroes[owner_index(b[pile][i])].hp <= 0:
				b.inactive.append(b[pile][i])
				b[pile].remove_at(i)

func _check_combat_end() -> bool:
	if run.phase != "combat": return false
	for enemy in run.combat.enemies:
		if enemy.hp > 0:
			return false
	for h in run.heroes:
		if h.hp <= 0:
			h.hp = maxi(1, int(ceil(h.max_hp * 0.25)))
		if "chalice" in run.relics:
			h.hp = mini(h.max_hp, h.hp + 3)
		h.block = 0
		h.turn_strength = 0
		h.turn_magic = 0
	Progression.award(profile, run)
	var kind = run.nodes[run.current].kind
	if kind == "elite":
		if "hourglass" not in profile.unlocked_relics:
			profile.unlocked_relics.append("hourglass")
			run.new_unlocks.append(content.relics.hourglass.name)
		var relic = _roll_relic()
		if relic != "":
			run.relics.append(relic)
	if kind == "boss":
		run.boss_defeated = true
	_make_reward()
	return true

func _make_reward() -> void:
	var pool: Array = []
	for id in content.cards:
		var c = content.cards[id]
		if c.owner in run.party and Progression.available(profile, c):
			pool.append({"id": id, "upgraded": false})
	_shuffle(pool)
	run.reward = pool.slice(0, 3)
	for hero in run.heroes:
		if relic_bonus(hero, "reward") > 0:
			for offered in run.reward:
				if content.cards[offered.id].owner == hero.id:
					offered.upgraded = true
					break
	run.phase = "reward"

func choose_reward(index: int) -> bool:
	if run.is_empty() or run.phase != "reward" or index < -1 or index >= run.reward.size():
		return false
	if index >= 0:
		run.deck.append(run.reward[index].duplicate(true))
	run.reward = []
	run.combat = {}
	run.phase = "map"
	checkpoint()
	return true

func _roll_relic() -> String:
	var pool: Array = []
	for id in content.relics:
		if id not in run.relics and (not content.relics[id].locked or id in profile.unlocked_relics):
			pool.append(id)
	return "" if pool.is_empty() else pool[rng.randi_range(0, pool.size() - 1)]

func take_treasure() -> bool:
	if not _room_is("treasure") or not Treasure.open(run):
		return false
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

func rest(heal: bool, card_index: int = -1) -> bool:
	if not _room_is("rest"):
		return false
	if heal:
		for h in run.heroes:
			h.hp = mini(h.max_hp, h.hp + int(ceil(h.max_hp * 0.3)))
	else:
		if card_index < 0 or card_index >= run.deck.size() or run.deck[card_index].upgraded:
			return false
		run.deck[card_index].upgraded = true
	run.phase = "map"
	checkpoint()
	return true

func choose_event(index: int) -> bool:
	if not _room_is("event") or index not in [0, 1]:
		return false
	var event_id = run.nodes[run.current].event
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
				_make_reward()
				checkpoint()
				return true
	run.phase = "map"
	checkpoint()
	return true

func descend() -> bool:
	if run.is_empty() or run.phase != "map" or not run.boss_defeated:
		return false
	_finish(true)
	checkpoint()
	return true

func _finish(won: bool) -> void:
	if run.phase in ["victory", "defeat"]:
		return
	run.phase = "victory" if won else "defeat"
	if won:
		profile.victories += 1
		for id in content.cards:
			if content.cards[id].locked and content.cards[id].owner in run.party and id not in profile.unlocked_cards:
				profile.unlocked_cards.append(id)
				run.new_unlocks.append(content.cards[id].name)
	profile.history.push_front({"won": won, "party": run.party.duplicate(), "rooms": run.visited.size(), "seed": run.seed})
	if profile.history.size() > 30:
		profile.history.resize(30)
	# A concluded run only retains its summary, not its acquired deck or relics.
	run.summary_cards = run.deck.size()
	run.inventory = {}
	for hero in run.heroes:
		hero.equipped_relic = ""
		hero.turn_strength = 0
		hero.turn_magic = 0
	run.deck = []
	run.team_relic = ""
	run.relics = []
	run.combat = {}
	run.reward = []

func _log(line: String) -> void:
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
	var bonus = int(hero.get("turn_strength", 0))
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
	if c.poison > 0:
		c.poison += relic_bonus(hero, "poison")
	return c

func item_targets(id: String) -> Array:
	if run.is_empty() or run.phase != "combat" or not content.items.has(id) or run.get("inventory", {}).get(id, 0) <= 0:
		return []
	var target = content.items[id].target
	if target == "team":
		return [0]
	var result: Array = []
	if target == "enemy":
		for i in range(run.combat.enemies.size()):
			if run.combat.enemies[i].hp > 0:
				result.append(i)
	else:
		for i in range(run.heroes.size()):
			var hero = run.heroes[i]
			if target == "fallen" and hero.hp <= 0:
				result.append(i)
			elif hero.hp > 0 and (target == "living" or (target == "caster" and hero.id in ["mage", "cleric"])):
				result.append(i)
	return result

func use_item(id: String, target: int) -> bool:
	if target not in item_targets(id):
		return false
	var item = content.items[id]
	var value = int(item.value)
	match item.effect:
		"energy": run.combat.energy += value
		"draw": _draw(value)
		"poison": run.combat.enemies[target].poison += value
		"heal": run.heroes[target].hp = mini(run.heroes[target].max_hp, run.heroes[target].hp + value)
		"block": run.heroes[target].block += value
		"strength": run.heroes[target].turn_strength = int(run.heroes[target].get("turn_strength", 0)) + value
		"magic": run.heroes[target].turn_magic = int(run.heroes[target].get("turn_magic", 0)) + value
		"revive":
			run.heroes[target].hp = maxi(1, int(ceil(run.heroes[target].max_hp * value / 100.0)))
			var inactive = run.combat.inactive
			for i in range(inactive.size() - 1, -1, -1):
				if owner_index(inactive[i]) == target:
					run.combat.discard.append(inactive[i])
					inactive.remove_at(i)
	run.inventory[id] -= 1
	_log("Usaste " + item.name + ".")
	checkpoint()
	return true
