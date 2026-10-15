extends Control
# Mouse/touch gesture only. Game remains the authority for target/energy validation.
var ui: Control
var index = -1
var origin = Vector2.ZERO
var dragging = false
var pointer_id = -1
var original: Button
var preview: Button
var highlights: Array = []
var hover_target = -1

static func install(controller: Control) -> Control:
	var drag = new()
	drag.ui = controller
	drag.name = "CardDrag"
	drag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	controller.layer.add_child(drag)
	return drag

func bind(card: Button, hand_index: int) -> void:
	card.gui_input.connect(func(event):
		if ui.combat_busy or is_instance_valid(ui.overlay): return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			arm(card, hand_index, card.get_global_transform() * event.position, -1)
		elif event is InputEventScreenTouch and event.pressed:
			arm(card, hand_index, card.get_global_transform() * event.position, event.index))

func arm(card: Button, hand_index: int, position_on_canvas: Vector2, pointer: int) -> void:
	index = hand_index
	original = card
	origin = position_on_canvas
	pointer_id = pointer

func _input(event: InputEvent) -> void:
	if index < 0: return
	if ui.combat_busy or is_instance_valid(ui.overlay): cancel(); return
	var point = origin
	var moved = false
	var released = false
	if pointer_id == -1 and event is InputEventMouseMotion:
		point = get_canvas_transform().affine_inverse() * event.position; moved = true
	elif pointer_id == -1 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		point = get_canvas_transform().affine_inverse() * event.position; released = not event.pressed
	elif event is InputEventScreenDrag and event.index == pointer_id:
		point = get_canvas_transform().affine_inverse() * event.position; moved = true
	elif event is InputEventScreenTouch and event.index == pointer_id:
		point = get_canvas_transform().affine_inverse() * event.position; released = not event.pressed
	if moved and not dragging and point.distance_to(origin) > 14: lift()
	if dragging and moved:
		preview.position = point - Vector2(110, 180)
		hover_target = target_at(point)
		get_viewport().set_input_as_handled()
	if released:
		if not dragging: index = -1; return
		var card_index = index
		var target = target_at(point)
		cancel()
		get_viewport().set_input_as_handled()
		if target >= 0: ui.animate_combat_action(card_index, target)

func lift() -> void:
	dragging = true
	original.modulate.a = 0.0
	preview = ui.card_panel(ui.game.run.combat.hand[index], 0, 0, 220, 340, func(): pass, false, true, ui.layer)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.z_index = 140
	var card = ui.game.effective_card(ui.game.run.combat.hand[index])
	for target in ui.game.valid_targets(index):
		var actor = ui.hero_art[target] if card.target in ["self", "ally", "all_allies"] else ui.enemy_art[target]
		var before = actor.get_child_count()
		ui.TargetGlow.attach(actor, true)
		if actor.get_child_count() > before: highlights.append(actor.get_child(0))

func target_at(point: Vector2) -> int:
	var card = ui.game.effective_card(ui.game.run.combat.hand[index])
	var prefix = "HeroTarget" if card.target in ["self", "ally", "all_allies"] else "EnemyTarget"
	for target in ui.game.valid_targets(index):
		var area = ui.layer.get_node_or_null(prefix + str(target))
		if area != null and area.get_global_rect().has_point(point): return target
	return -1

func cancel() -> void:
	index = -1
	dragging = false
	hover_target = -1
	if is_instance_valid(original): original.modulate.a = 1.0; original.set_pressed_no_signal(false)
	if is_instance_valid(preview): preview.queue_free()
	for glow in highlights:
		if is_instance_valid(glow): glow.queue_free()
	highlights.clear()
