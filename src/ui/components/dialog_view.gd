extends RefCounted
# UI only: callers own navigation and persistence.
static func build(ui: Control, title: String, text: String, actions: Array) -> Control:
	var overlay = Control.new()
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim = ColorRect.new()
	dim.color = Color(0.02, 0.025, 0.04, 0.82)
	ui.rect(dim, 0, 0, 1280, 720, overlay)
	var panel = ui.panel(280, 142, 720, 432, ui.GOLD, overlay)
	panel.name = "ModalFrame"
	preload("res://src/ui/components/modal_frame.gd").decorate(panel)
	ui.label_at(title, 330, 185, 620, 62, 32, ui.GOLD, overlay)
	ui.label_at(text, 330, 254, 620, 100 if actions.size() < 3 else 62, 22, ui.TEXT, overlay)
	for i in range(actions.size()):
		var action = actions[i]
		var y = (412 if actions.size() < 3 else 344) + i * 66
		var button = ui.button(action.text, 330, y, 620, 55, action.callback, action.get("enabled", true), overlay)
		button.name = action.get("id", "DialogAction%d" % i)
	return overlay
