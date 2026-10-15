extends RefCounted
## Presentation only. Callers commit the action before starting the flip.
static func play(card: Control, back: Texture2D, to_back: bool) -> void:
	var front: Array = card.get_children()
	var cover = TextureRect.new()
	cover.name = "CardBackCover"
	cover.texture = back
	cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cover.size = card.size
	cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cover.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	card.add_child(cover)
	cover.visible = not to_back
	if not to_back:
		for child in front:
			if child is CanvasItem: child.hide()
	var tween = card.create_tween()
	tween.tween_property(card, "scale:x", 0.02, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	cover.visible = to_back
	for child in front:
		if child is CanvasItem: child.visible = not to_back
	tween = card.create_tween()
	tween.tween_property(card, "scale:x", 1.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	if not to_back: cover.queue_free()
