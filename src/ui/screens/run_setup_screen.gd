extends RefCounted
const DIFFICULTIES = [
	["Normal", "difficulty/normal", "Enemigos y celdas sin cambios."],
	["Retorno I", "difficulty/return_1", "+6% vida enemiga · +1 daño\n+15% celdas"],
	["Retorno II", "difficulty/return_2", "+12% vida · +2 daño · +30% celdas\nContraataques cada 3 turnos"],
	["Retorno III", "difficulty/return_3", "+18% vida · +3 daño · +45% celdas\nContraataques cada 3 turnos"]
]
const CONDITIONS = [
	["normal", "Sin condición", "conditions/normal", "Una expedición sin efectos adicionales."],
	["tainted", "Interferida", "conditions/tainted", "+3 bloqueo enemigo cada 3 turnos."],
	["dangerous", "Peligrosa", "conditions/dangerous", "Más élites · +25% celdas\nContraataques cada 3 turnos"]
]

static func open(ui: Control, floor_number: int, start: Callable) -> void:
	ui.close_modal()
	var panel = Control.new()
	panel.name = "RunSetup"
	panel.z_index = 200
	ui.add_child(panel)
	ui.overlay = panel
	var shade = ColorRect.new(); shade.color = Color(0,0,0,0.85)
	ui.rect(shade,0,0,1280,720,panel)
	ui.panel(125,48,1030,624,ui.GOLD,panel)
	ui.label_at("Preparar la expedición",160,70,960,48,30,ui.GOLD,panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var limit = preload("res://src/rules/adventure_extensions.gd").difficulty_limit(ui.game.profile)
	var selected = {"difficulty":clampi(int(ui.game.profile.get("preferred_difficulty",0)),0,limit), "variant":ui.game.profile.get("preferred_variant","normal")}
	if selected.variant not in ["normal","tainted","dangerous"]: selected.variant = "normal"
	ui.label_at("Dificultad",170,124,930,28,20,ui.TEXT,panel)
	var difficulties = ButtonGroup.new()
	for i in range(DIFFICULTIES.size()):
		var entry: Array = DIFFICULTIES[i]
		var detail = entry[2] if i <= limit else "Ganá en %s para desbloquear." % DIFFICULTIES[i-1][0]
		card(ui,panel,"DifficultyCard%d" % i,entry[0],entry[1],detail,170+i*238,160,226,160,difficulties,i==selected.difficulty,i<=limit,func(): selected.difficulty=i)
	ui.label_at("Condición adicional",170,332,930,28,20,ui.TEXT,panel)
	var conditions = ButtonGroup.new()
	for i in range(CONDITIONS.size()):
		var entry: Array = CONDITIONS[i]
		card(ui,panel,"ConditionCard_"+entry[0],entry[1],entry[2],entry[3],170+i*318,368,306,148,conditions,entry[0]==selected.variant,true,func(): selected.variant=entry[0])
	ui.label_at("La configuración queda fija para toda esta aventura.",170,526,940,28,17,ui.MUTED,panel).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var begin_button = ui.button("Iniciar aventura",485,566,310,48,func():
		ui.game.profile.preferred_difficulty = selected.difficulty
		ui.game.profile.preferred_variant = selected.variant
		start.call(floor_number),true,panel)
	begin_button.name = "StartAdventure"
	begin_button.icon = preload("res://assets/ui/play.svg")
	begin_button.expand_icon = true
	begin_button.add_theme_constant_override("icon_max_width", 30)
	begin_button.add_theme_constant_override("h_separation", 10)
	ui.button("Volver",540,620,200,34,ui.close_modal,true,panel).name = "CancelRunSetup"

static func card(ui: Control, parent: Control, id: String, title: String, art: String, detail: String, x: float, y: float, w: float, h: float, group: ButtonGroup, selected: bool, enabled: bool, action: Callable) -> Button:
	var button = ui.button("",x,y,w,h,action,enabled,parent)
	button.name = id
	button.toggle_mode = true
	button.button_group = group
	button.button_pressed = selected
	button.tooltip_text = title + ": " + detail
	var picture = TextureRect.new()
	picture.texture = load("res://assets/run_setup/%s.png" % art)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not enabled: picture.modulate = Color(0.5,0.5,0.5,0.65)
	ui.rect(picture,(w-58)/2,10,58,58,button)
	ui.label_at(title,10,70,w-20,28,18,ui.TEXT if enabled else ui.MUTED,button).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.label_at(detail,12,100,w-24,h-110,14,ui.TEXT if enabled else ui.MUTED,button).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var indicator = ui.label_at("Elegida" if selected else ("Bloqueada" if not enabled else ""),8,5,w-16,20,12,ui.GOLD,button)
	indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	button.toggled.connect(func(on): indicator.text = "Elegida" if on else ("Bloqueada" if not enabled else ""))
	return button
