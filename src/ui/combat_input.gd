extends RefCounted
# Uses the same validated controller actions as touch and drag.
static func handle(ui: Control, event: InputEvent) -> bool:
	if ui.screen != "combat" or ui.combat_busy or is_instance_valid(ui.overlay): return false
	var command = ""
	var card_index = -1
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9: card_index = event.keycode-KEY_1
		match event.keycode:
			KEY_LEFT: command = "previous"
			KEY_RIGHT: command = "next"
			KEY_UP,KEY_DOWN,KEY_TAB: command = "target"
			KEY_ENTER,KEY_KP_ENTER: command = "confirm"
			KEY_SPACE: command = "end"
			KEY_O: command = "objective"
			KEY_L: command = "synergy"
			KEY_J: command = "deck"
			KEY_B: command = "bag"
	elif event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_LEFT_SHOULDER: command = "previous"
			JOY_BUTTON_RIGHT_SHOULDER: command = "next"
			JOY_BUTTON_DPAD_LEFT,JOY_BUTTON_DPAD_RIGHT,JOY_BUTTON_DPAD_UP,JOY_BUTTON_DPAD_DOWN: command = "target"
			JOY_BUTTON_A: command = "confirm"
			JOY_BUTTON_Y: command = "end"
			JOY_BUTTON_X: command = "objective"
			JOY_BUTTON_LEFT_STICK: command = "synergy"
			JOY_BUTTON_START: command = "menu"
			JOY_BUTTON_B: command = "cancel"
	if command == "" and card_index < 0: return false
	var count = ui.game.run.combat.hand.size()
	if command in ["previous","next"] and count > 0: card_index = posmod(ui.selected_card + (-1 if command == "previous" else 1),count)
	if card_index >= 0:
		if card_index < count: ui.keyboard_target = -1;ui.select_card(card_index)
	elif command in ["target","confirm"]:
		var targets: Array = ui.game.synergy_targets(ui.selected_synergy) if ui.selected_synergy != "" else ui.game.valid_targets(ui.selected_card)
		if targets.is_empty(): ui.audio.play_sfx("error");return true
		if command == "target": ui.keyboard_target = targets[(targets.find(ui.keyboard_target)+1)%targets.size()]
		elif ui.keyboard_target not in targets: ui.keyboard_target = targets[0]
		if command == "confirm": ui.target_clicked(ui.keyboard_target)
		else:
			var ally = false
			if ui.selected_card >= 0:
				var instance: Dictionary = ui.game.run.combat.hand[ui.selected_card]
				ally = ui.game.content.cards[instance.id].target in ["self","ally","all_allies"]
			var target = ui.layer.get_node_or_null(("HeroTarget" if ally else "EnemyTarget")+str(ui.keyboard_target))
			if target != null: target.grab_focus()

	elif command == "objective":
		if ui.game.polish_action("boss_objective"): ui.audio.play_sfx("magic");ui.render()
		else: ui.audio.play_sfx("error")
	elif command == "synergy":
		var combos: Array = ui.game.available_synergies()
		if not combos.is_empty():
			var ids: Array = combos.map(func(combo): return combo.id)
			ui.selected_synergy=ids[(ids.find(ui.selected_synergy)+1)%ids.size()];ui.selected_card=-1;ui.keyboard_target=-1;ui.render()
	elif command == "end": ui.animate_combat_action()
	elif command == "deck": ui.open_deck()
	elif command == "bag": ui.screen = "items";ui.render()
	elif command == "menu": ui.pause_menu()
	elif command == "cancel": ui.back()
	return true
