extends RefCounted
const BattleAudio = preload("res://src/audio/battle_audio.gd")
# Coordinates committed actions and their presentation; save precedes animation.
static func run(ui: Control, hand_index: int = -1, target_index: int = -1, synergy_id: String = "") -> void:
	if ui.combat_busy: return
	var previous_speed = Engine.time_scale
	Engine.time_scale = preload("res://src/presentation/preferences.gd").speed()
	await present(ui, hand_index, target_index, synergy_id)
	Engine.time_scale = previous_speed

static func present(ui: Control, hand_index: int, target_index: int, synergy_id: String) -> void:
	if ui.combat_busy or ui.game.run.phase != "combat":
		return
	if hand_index >= ui.game.run.combat.hand.size(): return
	var returning: Array = ui.game.run.combat.get("reserved", []).duplicate(true) if hand_index < 0 and synergy_id == "" else []
	var before = ui.game.run.heroes.duplicate(true)
	var old_enemies = ui.game.run.combat.enemies.duplicate(true)
	var owner = -1
	var offensive = false
	var defensive = false
	var healing = false
	var poisonous = false
	var motion = "attack"
	var prepared = false
	if hand_index >= 0:
		var instance = ui.game.run.combat.hand[hand_index]
		var card = ui.game.content.card(instance)
		prepared = card.get("charge", false)
		offensive = (card.damage > 0 or card.poison > 0) and not prepared
		defensive = card.block > 0
		healing = card.heal > 0
		poisonous = card.poison > 0
		owner = ui.game.owner_index(instance)
		motion = preload("res://src/presentation/action_motion.gd").for_card(card)
	var spent_indices: Array = [hand_index] if hand_index >= 0 else []
	if hand_index >= 0 and int(ui.game.content.cards[ui.game.run.combat.hand[hand_index].id].get("discard_cost",0)) > 0:
		var others: Array = range(ui.game.run.combat.hand.size()).filter(func(i):return i != hand_index)
		if not others.is_empty(): spent_indices.append(others.back())
	if synergy_id != "":
		for combo in ui.game.available_synergies():
			if combo.id == synergy_id:
				spent_indices = combo.indices.duplicate()
	elif hand_index < 0:
		# Snapshot the outgoing hand before end_turn discards it and draws another.
		spent_indices = range(ui.game.run.combat.hand.size())
	# Resolve and persist first. Closing Android during the animation never replays it.
	var accepted: bool
	if synergy_id != "":
		accepted = ui.game.play_synergy(synergy_id, target_index)
	else:
		accepted = ui.game.play_card(hand_index, target_index) if hand_index >= 0 else ui.game.end_turn()
	if not accepted:
		ui.audio.play_sfx("error")
		return
	ui.audio.play_sfx("card_use" if hand_index >= 0 or synergy_id != "" else "ash", -6)
	if healing: ui.audio.play_sfx("heal")
	if poisonous: ui.audio.play_sfx("poison", -4)
	if hand_index >= 0 or synergy_id != "":
		ui.layer.get_node("CombatHUD").update_energy(ui.game.run.combat.energy)
	var impacts: Array = ui.game.resolved_card_hits.duplicate(true) if hand_index >= 0 or synergy_id != "" else []
	ui.combat_busy = true
	for tip in ui.get_tree().get_nodes_in_group("combat_tip"): tip.queue_free()
	var ash_effects: Array = []
	var hand_view = ui.layer.get_node_or_null("CombatHand")
	if hand_view != null:
		var cards = hand_view.get_child(0).get_children()
		for index in spent_indices:
			for card in cards:
				if int(card.get_meta("hand_index", -1)) == index:
					ash_effects.append(preload("res://src/presentation/card_ash.gd").play(ui.layer, card))
	for actor in ui.hero_art.values() + ui.enemy_art.values():
		var glow = actor.get_node_or_null("TargetGlow")
		if glow != null:
			glow.hide()
	# End-turn discard finishes before poison reactions or enemy actions begin.
	if hand_index < 0 and synergy_id == "":
		while ash_effects.any(func(effect): return is_instance_valid(effect)):
			await ui.get_tree().process_frame
	if synergy_id != "":
		preload("res://src/presentation/pair_link_fx.gd").play(ui, synergy_id)
		ui.CombatEffects.attack_flash(ui.layer)
		for actor in ui.hero_art.values():
			await actor.play_once("attack")
		if not impacts.is_empty():
			await preload("res://src/presentation/card_impacts.gd").play(ui, impacts, motion)
	if prepared: motion = "guard"
	if owner >= 0 and ui.game.run.party[owner] in ui.ANIMATED_HEROES:
		if offensive:
			ui.CombatEffects.attack_flash(ui.layer)
		if (offensive or defensive) and impacts.is_empty():
			BattleAudio.hero(ui.audio, ui.game.run.party[owner], "attack" if offensive else "defense")
			var cut_in = preload("res://src/presentation/hero_cut_in.gd").play(ui.layer, ui.game.run.party[owner], "attack" if offensive else "defense")
			if cut_in != null:
				await cut_in.finished
		if impacts.is_empty():
			await ui.hero_art[owner].play_once(motion)
		else:
			await preload("res://src/presentation/card_impacts.gd").play(ui, impacts, motion)
	# The committed result can already be reward/defeat; show the old arena until
	# reactions finish, so a lethal strike and a falling hero remain visible.
	var current_enemies = ui.game.run.combat.get("enemies", [])
	for i in range(old_enemies.size()):
		var enemy_hp = int(current_enemies[i].hp) if i < current_enemies.size() else int(old_enemies[i].hp)
		if hand_index < 0 and synergy_id == "":
			enemy_hp = preload("res://src/presentation/prepared_strikes.gd").before_hp(ui.game.resolved_prepared_hits, i, enemy_hp)
		var poison_hit: Dictionary = ui.game.resolved_poison_hits.get(i, {}) if hand_index < 0 and synergy_id == "" else {}
		if not poison_hit.is_empty() and int(poison_hit.lost) > 0:
			ui.enemy_health[i].animate_to(poison_hit.hp)
			await ui.enemy_art[i].play_once("poison")
		if i < current_enemies.size() and old_enemies[i].hp <= 0 and enemy_hp > 0:
			ui.enemy_art[i].set_fallen(false)
			ui.enemy_health[i].animate_to(enemy_hp)
		if i < current_enemies.size() and old_enemies[i].hp > 0:
			if enemy_hp > old_enemies[i].hp:
				ui.enemy_health[i].animate_to(enemy_hp)
				preload("res://src/presentation/support_feedback.gd").play(ui.layer,ui.enemy_art[i],"heal")
			if enemy_hp < old_enemies[i].hp:
				ui.enemy_health[i].animate_to(enemy_hp)
			if enemy_hp <= 0:
				ui.audio.play_sfx("death")
				ui.audio.play_sfx("ash", -8)
				if poison_hit.is_empty(): ui.flash_hit(ui.enemy_art[i])
				await ui.enemy_art[i].play_once("death")
			elif enemy_hp < old_enemies[i].hp and impacts.is_empty() and poison_hit.is_empty():
				await ui.enemy_art[i].play_once("hurt")
		if hand_index < 0 and synergy_id == "":
			var visual = ui.game.content.enemies[old_enemies[i].id].visual
			await preload("res://src/presentation/enemy_action_playback.gd").play(ui,i,visual)
	if hand_index < 0 and synergy_id == "" and not ui.game.resolved_prepared_hits.is_empty():
		await preload("res://src/presentation/prepared_strikes.gd").play(ui)
	for i in range(before.size()):
		var after = ui.game.run.heroes[i]
		ui.hero_health[i].animate_to(after.hp)
		if hand_index < 0 and synergy_id == "":
			preload("res://src/presentation/card_impacts.gd").update_block(ui.hero_health[i], after.block)
		var received_hit = ui.game.resolved_enemy_hits.values().any(func(hits): return hits.any(func(hit): return int(hit.owner) == i)) if hand_index < 0 and synergy_id == "" else false
		if after.hp > before[i].hp:
			preload("res://src/presentation/support_feedback.gd").play(ui.layer,ui.hero_art[i],"heal")
		if after.block > before[i].block and (hand_index >= 0 or synergy_id != ""):
			preload("res://src/presentation/card_impacts.gd").update_block(ui.hero_health[i], after.block)
			preload("res://src/presentation/support_feedback.gd").play(ui.layer,ui.hero_art[i],"block")
		if after.hp < before[i].hp and not received_hit:
			ui.audio.play_sfx("hurt", -5)
			ui.flash_hit(ui.hero_art[i])
		if ui.game.run.party[i] not in ui.ANIMATED_HEROES:
			continue
		if before[i].hp > 0 and after.hp <= 0:
			if not ui.hero_art[i].fallen: await ui.hero_art[i].play_once("death")
		elif before[i].hp <= 0 and after.hp > 0:
			await ui.hero_art[i].play_once("revive")
		elif after.hp < before[i].hp and impacts.is_empty() and not received_hit:
			await ui.hero_art[i].play_once("hurt")
	for bar in ui.hero_health.values() + ui.enemy_health.values():
		if bar.animating:
			await bar.animation_finished
	while ash_effects.any(func(effect): return is_instance_valid(effect)):
		await ui.get_tree().process_frame
	while not ui.get_tree().get_nodes_in_group("block_ash").is_empty():
		await ui.get_tree().process_frame
	while ui.layer.get_children().any(func(child): return child.get_script() == preload("res://src/presentation/support_feedback.gd")):
		await ui.get_tree().process_frame
	await ui.get_tree().create_timer(0.18).timeout
	if ui.game.run.phase == "reward":
		await ui.CombatEffects.leave_room(ui.layer, ui.hero_art.values())
	ui.combat_busy = false
	ui.continue_run()
	if not returning.is_empty() and ui.game.run.phase == "combat" and not ui.game.run.combat.hand.is_empty() and ui.game.run.combat.hand[0] == returning[0]:
		await preload("res://src/ui/card_reserve_navigation.gd").reveal(ui)
