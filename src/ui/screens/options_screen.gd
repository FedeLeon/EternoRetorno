extends RefCounted
# Settings layout; controller persists values and applies them through GameAudio.
static func build(ui: Control) -> void:
	var shade = ColorRect.new()
	shade.color = Color(0, 0, 0, 0.75)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(shade, 0, 0, 1280, 720)
	ui.panel(350, 112, 580, 498, Color("8a799b"))
	ui.label_at("Opciones", 390, 136, 500, 46, 32).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var settings: Dictionary = ui.game.profile.get("settings", {})
	var rows = [["volume", "Volumen general", "Volume", 1.0], ["music_volume", "Música", "MusicVolume", 0.75], ["sfx_volume", "Efectos y ambiente", "SfxVolume", 0.85]]
	for i in range(rows.size()):
		var row: Array = rows[i]
		ui.label_at(row[1], 390, 197 + i * 91, 500, 32)
		var slider = HSlider.new()
		slider.name = row[2]
		slider.min_value = 0
		slider.max_value = 100
		slider.step = 1
		slider.value = float(settings.get(row[0], row[3])) * 100
		ui.rect(slider, 390, 236 + i * 91, 500, 32)
		slider.value_changed.connect(func(value): ui.set_option(row[0], value / 100.0))
	var fullscreen = CheckButton.new()
	fullscreen.name = "Fullscreen"
	fullscreen.text = "Pantalla completa"
	fullscreen.button_pressed = settings.get("fullscreen", false)
	fullscreen.disabled = OS.has_feature("mobile")
	if fullscreen.disabled: fullscreen.tooltip_text = "Android utiliza pantalla completa."
	ui.rect(fullscreen, 390, 482, 500, 42)
	fullscreen.toggled.connect(func(value): ui.set_option("fullscreen", value))
	ui.button("Volver", 390, 544, 500, 48, func(): ui.screen = "home"; ui.render())
