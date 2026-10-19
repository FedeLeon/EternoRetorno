extends RefCounted
static func build(ui: Control) -> void:
	var shade = ColorRect.new(); shade.color = Color(0,0,0,0.8)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.rect(shade,0,0,1280,720)
	ui.panel(160,80,960,590,ui.GOLD)
	ui.label_at("Opciones",210,100,860,42,30,ui.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var settings: Dictionary = ui.game.profile.get("settings", {})
	var rows = [["volume","Volumen general","Volume",1.0],["music_volume","Música","MusicVolume",0.75],["sfx_volume","Efectos","SfxVolume",0.85],["ambience_volume","Ambiente","AmbienceVolume",1.0],["flash_intensity","Intensidad de destellos","FlashIntensity",0.6]]
	for i in range(rows.size()):
		var row: Array = rows[i]
		ui.label_at(row[1],210,160+i*76,395,28,19)
		var amount = ui.label_at("%d %%" % roundi(float(settings.get(row[0],row[3]))*100),520,160+i*76,85,28,16,ui.GOLD)
		amount.name = row[2]+"Value"
		amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		var slider = HSlider.new(); slider.name = row[2]
		slider.max_value = 100; slider.step = 1
		slider.value = float(settings.get(row[0],row[3])) * 100
		ui.rect(slider,210,194+i*76,395,26)
		slider.value_changed.connect(func(value): amount.text="%d %%" % roundi(value); ui.set_option(row[0],value/100.0))
	ui.label_at("Velocidad de combate",680,160,390,32,21)
	var speed = OptionButton.new(); speed.name = "CombatSpeed"
	for text in ["Normal · 1×","Ágil · 1,5×","Rápido · 2×"]: speed.add_item(text)
	speed.select([1.0,1.5,2.0].find(float(settings.get("combat_speed",1.0))))
	ui.rect(speed,680,203,390,45)
	speed.item_selected.connect(func(index): ui.set_option("combat_speed",[1.0,1.5,2.0][index]))
	for row in [["reduce_cutins","Reducir primeros planos",285],["low_effects","Menos partículas y luces",345],["large_text","Textos más grandes",405],["fullscreen","Pantalla completa",465]]:
		var toggle = CheckButton.new(); toggle.text = row[1]
		toggle.name = "Fullscreen" if row[0] == "fullscreen" else row[0]
		toggle.button_pressed = float(settings.get("text_scale",1.0)) > 1 if row[0] == "large_text" else settings.get(row[0],false)
		toggle.disabled = row[0] == "fullscreen" and OS.has_feature("mobile")
		ui.rect(toggle,680,row[2],390,46)
		toggle.toggled.connect(func(value): ui.set_option("text_scale" if row[0] == "large_text" else row[0], (1.12 if value else 1.0) if row[0] == "large_text" else value))
	var impact=CheckButton.new();impact.text="Pausas breves en golpes fuertes";impact.button_pressed=settings.get("hit_pause",true)
	var cinematic = CheckButton.new()
	cinematic.name = "AutoCinematics"
	cinematic.text = "Cinemáticas automáticas"
	cinematic.button_pressed = settings.get("auto_cinematics",true)
	ui.rect(cinematic,210,552,395,42)
	cinematic.toggled.connect(func(value):ui.set_option("auto_cinematics",value))
	ui.rect(impact,680,515,390,42);impact.toggled.connect(func(value):ui.set_option("hit_pause",value))

	var force=OptionButton.new();force.name="ImpactStrength"
	for caption in ["Impactos sin sacudidas", "Impactos suaves", "Impactos intensos"]: force.add_item(caption)
	force.select(0 if float(settings.get("impact_strength",0.65))==0 else 2 if float(settings.get("impact_strength",0.65))>=1 else 1)
	ui.rect(force,680,562,390,34);force.item_selected.connect(func(index):ui.set_option("impact_strength",[0.0,0.65,1.0][index]))
	ui.button("Cómo jugar",905,105,172,38,func(): preload("res://src/ui/tutorial_navigation.gd").open(ui)).add_theme_font_size_override("font_size",17)
