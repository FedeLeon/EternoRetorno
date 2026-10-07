extends RefCounted
static func open(ui: Control, title: String, text: String) -> void:
	ui.close_modal()
	var overlay = Control.new()
	overlay.z_as_relative = false; overlay.z_index = 200
	ui.add_child(overlay); overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.overlay = overlay
	var shade = ColorRect.new(); shade.color = Color(0,0,0,0.86)
	ui.rect(shade,0,0,1280,720,overlay)
	ui.panel(210,95,860,550,ui.GOLD,overlay)
	ui.label_at(title,245,115,790,55,28,ui.GOLD,overlay)
	var scroll = ScrollContainer.new()
	ui.rect(scroll,245,182,790,360,overlay)
	var label = Label.new()
	label.text = text; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 766
	label.add_theme_font_size_override("font_size",20)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(label)
	ui.button("Volver",780,571,255,45,ui.close_modal,true,overlay)
