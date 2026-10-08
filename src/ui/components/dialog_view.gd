extends RefCounted
# UI only: callers own navigation and persistence.
static func build(ui: Control, title: String, text: String, actions: Array, body_height: float = 72) -> Control:
	var overlay = Control.new()
	# Above raised cards, their cost digits and arena effects, including the dimmer.
	overlay.z_as_relative = false
	overlay.z_index = 200
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim = ColorRect.new()
	dim.color = Color(0.02, 0.025, 0.04, 0.82)
	ui.rect(dim, 0, 0, 1280, 720, overlay)
	var extra = maxf(0, body_height - 72)
	var height = minf(644, 208 + extra + actions.size()*64)
	var top = (720-height)/2
	var panel = ui.panel(280,top,720,height,ui.GOLD,overlay)
	panel.name = "ModalFrame"
	preload("res://src/ui/components/modal_frame.gd").decorate(panel)
	ui.label_at(title,316,top+22,648,64,29,ui.GOLD,overlay).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at(text,316,top+96,648,72+extra,21,ui.TEXT,overlay).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	for i in range(actions.size()):
		var action=actions[i]
		var button=ui.button(action.text,316,top+184+extra+i*64,648,48,action.callback,action.get("enabled",true),overlay)
		button.name=action.get("id","DialogAction%d" % i)
	return overlay
