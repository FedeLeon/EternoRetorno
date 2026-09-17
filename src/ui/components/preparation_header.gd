extends RefCounted
# Shared camp/preparation header; souls are optional and only passed by camp.
static func build(ui: Control, title: String, menu: Callable, souls: int = -1) -> void:
	ui.panel(0, 0, 1280, 84).name = "PreparationHeader"
	ui.label_at(title, 28, 16, 795 if souls >= 0 else 1070, 52, 27, ui.GOLD)
	if souls >= 0:
		preload("res://src/ui/components/soul_counter.gd").attach(ui, souls, Vector2(866, 16))
	ui.button("Menú", 1134, 18, 110, 48, menu)
