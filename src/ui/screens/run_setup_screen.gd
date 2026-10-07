extends RefCounted
static func open(ui: Control, floor_number: int, start: Callable) -> void:
	ui.close_modal()
	var panel = Control.new()
	panel.z_index = 200
	ui.add_child(panel)
	ui.overlay = panel
	var shade = ColorRect.new(); shade.color = Color(0,0,0,0.85)
	ui.rect(shade,0,0,1280,720,panel)
	ui.panel(220,90,840,545,ui.GOLD,panel)
	ui.label_at("Preparar la expedición",260,110,760,48,30,ui.GOLD,panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at("Cada nivel: +6% vida enemiga, +1 daño y +15% almas.\nRetorno II y III añaden contraataques cada tres turnos.",260,165,760,65,20,ui.TEXT,panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var difficulty = OptionButton.new(); difficulty.name = "RunDifficulty"
	var limit = preload("res://src/rules/adventure_extensions.gd").difficulty_limit(ui.game.profile)
	for i in range(limit+1): difficulty.add_item(["Normal", "Retorno I", "Retorno II", "Retorno III"][i], i)
	difficulty.select(clampi(int(ui.game.profile.get("preferred_difficulty",0)),0,limit))
	ui.rect(difficulty,300,255,680,50,panel)
	var variant = OptionButton.new(); variant.name = "RunVariant"
	for text in ["Sin condición adicional", "Profanada: +3 bloqueo enemigo cada 3 turnos", "Expedición peligrosa: más élites y +25% almas"]: variant.add_item(text)
	variant.select(maxi(0,["normal","tainted","dangerous"].find(ui.game.profile.get("preferred_variant","normal"))))
	ui.rect(variant,300,330,680,50,panel)
	ui.label_at("La configuración queda fija para toda esta aventura.",270,405,740,35,19,ui.MUTED,panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var begin_button = ui.button("Iniciar aventura",300,465,680,58,func():
		ui.game.profile.preferred_difficulty = difficulty.selected
		ui.game.profile.preferred_variant = ["normal","tainted","dangerous"][variant.selected]
		start.call(floor_number),true,panel)
	begin_button.name = "StartAdventure"
	ui.button("Volver",300,543,680,45,ui.close_modal,true,panel)
