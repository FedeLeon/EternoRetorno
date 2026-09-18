extends RefCounted
# Coordinates committed actions and their presentation; save precedes animation.
static func run(ui: Control, hand_index: int = -1, target_index: int = -1, synergy_id: String = "") -> void:
	if ui.combat_busy or ui.game.run.phase != "combat":
		return
	var before = ui.game.run.heroes.duplicate(true)
	var old_enemies = ui.game.run.combat.enemies.duplicate(true)
	var owner = -1
	var offensive = false
	var defensive = false
	var motion = "attack"
	if hand_index >= 0:
		var instance = ui.game.run.combat.hand[hand_index]
		var card = ui.game.content.card(instance)
		offensive = card.damage > 0 or card.poison > 0
		defensive = card.block > 0
		owner = ui.game.owner_index(instance)
		motion = "heavy" if card.cost >= 2 else "attack"
		if card.owner == "mage":
			motion = "heavy" if card.target == "all_enemies" else "attack"
		if instance.id == "guardian_bash":
			motion = "bash"
		if card.damage == 0:
			motion = "guard"
		if card.owner == "cleric":
			motion = "attack" if card.damage > 0 else ("heal" if card.heal > 0 else "guard")
		if instance.id == "rogue_venom":
			motion = "poison"
	var spent_indices: Array = [hand_index] if hand_index >= 0 else []
	if synergy_id != "":
		for combo in ui.game.available_synergies():
			if combo.id == synergy_id:
				spent_indices = combo.indices.duplicate()
	# Resolve and persist first. Closing Android during the animation never replays it.
	var accepted: bool
	if synergy_id != "":
		accepted = ui.game.play_synergy(synergy_id, target_index)
	else:
		accepted = ui.game.play_card(hand_index, target_index) if hand_index >= 0 else ui.game.end_turn()
	if not accepted:
		return
	ui.combat_busy = true
	var ash_effects: Array = []
	var hand_view = ui.layer.get_node_or_null("CombatHand")
	if hand_view != null:
		var cards = hand_view.get_child(0).get_children()
		for index in spent_indices:
			if index >= 0 and index < cards.size():
				ash_effects.append(preload("res://src/presentation/card_ash.gd").play(ui.layer, cards[index]))
	for actor in ui.hero_art.values() + ui.enemy_art.values():
		var glow = actor.get_node_or_null("TargetGlow")
		if glow != null:
			glow.hide()
	if synergy_id != "":
		ui.CombatEffects.attack_flash(ui.layer)
		for actor in ui.hero_art.values():
			await actor.play_once("attack")
	if owner >= 0 and ui.game.run.party[owner] in ui.ANIMATED_HEROES:
		if offensive:
			ui.CombatEffects.attack_flash(ui.layer)
		if offensive or defensive:
			var cut_in = preload("res://src/presentation/hero_cut_in.gd").play(ui.layer, ui.game.run.party[owner], "attack" if offensive else "defense")
			if cut_in != null:
				await cut_in.finished
		await ui.hero_art[owner].play_once(motion)
	# The committed result can already be reward/defeat; show the old arena until
	# reactions finish, so a lethal strike and a falling hero remain visible.
	var current_enemies = ui.game.run.combat.get("enemies", [])
	for i in range(old_enemies.size()):
		if i < current_enemies.size() and old_enemies[i].hp > 0:
			if current_enemies[i].hp < old_enemies[i].hp:
				ui.enemy_health[i].animate_to(current_enemies[i].hp)
			if current_enemies[i].hp <= 0:
				ui.flash_hit(ui.enemy_art[i])
				await ui.enemy_art[i].play_once("death")
			elif current_enemies[i].hp < old_enemies[i].hp:
				await ui.enemy_art[i].play_once("hurt")
			if hand_index < 0 and synergy_id == "" and current_enemies[i].hp > 0 and old_enemies[i].intent.get("damage", 0) > 0:
				ui.CombatEffects.attack_flash(ui.layer)
				await ui.enemy_art[i].play_once("attack")
	for i in range(before.size()):
		var after = ui.game.run.heroes[i]
		ui.hero_health[i].animate_to(after.hp)
		if after.hp < before[i].hp:
			ui.flash_hit(ui.hero_art[i])
		if ui.game.run.party[i] not in ui.ANIMATED_HEROES:
			continue
		if before[i].hp > 0 and after.hp <= 0:
			await ui.hero_art[i].play_once("death")
		elif before[i].hp <= 0 and after.hp > 0:
			await ui.hero_art[i].play_once("revive")
		elif after.hp < before[i].hp:
			await ui.hero_art[i].play_once("hurt")
		elif hand_index < 0 and after.block < before[i].block:
			await ui.hero_art[i].play_once("guard")
	for bar in ui.hero_health.values() + ui.enemy_health.values():
		if bar.animating:
			await bar.animation_finished
	while ash_effects.any(func(effect): return is_instance_valid(effect)):
		await ui.get_tree().process_frame
	await ui.get_tree().create_timer(0.18).timeout
	if ui.game.run.phase == "reward":
		await ui.CombatEffects.leave_room(ui.layer, ui.hero_art.values())
	ui.combat_busy = false
	ui.continue_run()
