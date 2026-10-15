extends RefCounted
## Read-only full-view artwork; uses the shared modal/back navigation contract.
static func open(ui: Control, texture: Texture2D, return_focus: Control) -> void:
	ui.close_modal()
	var overlay = Control.new()
	overlay.name = "ArtworkViewer"
	overlay.z_as_relative = false
	overlay.z_index = 200
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.overlay = overlay
	var background = ColorRect.new()
	background.color = Color("080a10")
	overlay.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var picture = TextureRect.new()
	picture.name = "Artwork"
	picture.texture = texture
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(picture)
	picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var back = ui.button("Volver",0,0,160,44,ui.close_modal,true,overlay)
	back.name = "CloseArtwork"
	back.tooltip_text = "Volver a la colección"
	back.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	back.position = Vector2(overlay.size.x-180,18)
	back.grab_focus()
	overlay.tree_exited.connect(func():
		if is_instance_valid(return_focus) and return_focus.is_inside_tree():
			return_focus.grab_focus()
	)
