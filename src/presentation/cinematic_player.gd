extends Control
# Illustrated, real-time cutscenes. Never changes game state or grants rewards.
signal finished
const Preferences = preload("res://src/presentation/preferences.gd")
var definition: Dictionary = {}
var chapter = 0
var elapsed = 0.0
var total_elapsed = 0.0
var ended = false
var paused = false
var backdrop: TextureRect
var heading: Label
var subtitle: Label
var progress: ProgressBar
var chapter_label: Label
var camera_tween: Tween
var transition: TextureRect
var accent = Color.WHITE

func _ready() -> void:
	name = "CinematicPlayer"
	size = Vector2(1280,720)
	z_index = 500
	mouse_filter = Control.MOUSE_FILTER_STOP
	accent = Color(definition.get("color","b6adbf"))
	var black = ColorRect.new()
	black.color = Color.BLACK
	_place(black,Rect2(0,0,1280,720))
	backdrop = TextureRect.new()
	backdrop.texture = load(definition.chapters[0].get("image","res://assets/cinematics/%s.png" % definition.background))
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_place(backdrop,Rect2(-40,-24,1360,768))
	var veil = ColorRect.new()
	veil.color = Color(0.02,0.025,0.045,0.15 if definition.chapters[0].has("image") else 0.24)
	_place(veil,Rect2(0,0,1280,720))
	if definition.has("portrait") and not definition.chapters[0].has("image"):
		var portrait = TextureRect.new()
		portrait.name = "HeroPortrait"
		portrait.texture = load("res://assets/cinematics/portraits/%s.png" % definition.portrait)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		_place(portrait,Rect2(60,110,1150,430))
		if not Preferences.low_quality():
			portrait.modulate.a = 0
			portrait.create_tween().tween_property(portrait,"modulate:a",1.0,0.55)
	for region in [Rect2(0,0,1280,74),Rect2(0,538,1280,182)]:
		var bar = ColorRect.new()
		bar.color = Color(0.02,0.018,0.028,0.94)
		_place(bar,region)
	var line = ColorRect.new()
	line.color = accent.darkened(0.5)
	_place(line,Rect2(48,538,1184,1))
	heading = _label(28,Rect2(80,552,1120,40),accent)
	subtitle = _label(22,Rect2(100,598,1080,65),Color("eee6d7"))
	chapter_label = _label(15,Rect2(44,20,400,30),Color("b2abba"))
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	progress = ProgressBar.new()
	progress.show_percentage = false
	progress.max_value = 1
	_place(progress,Rect2(48,708,1184,3))
	_button("Omitir",Rect2(1110,16,126,42),finish,"SkipCinematic")
	_button("Continuar",Rect2(1055,664,181,42),advance,"NextCinematic")
	_button("Pausar",Rect2(884,664,154,42),toggle_pause,"PauseCinematic")
	var hint = _label(14,Rect2(48,671,770,30),Color("aaa3af"))
	hint.text = "Espacio / A: continuar · Escape / B: omitir · P: pausar"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_show_chapter()

func _place(node: Control, bounds: Rect2) -> void:
	node.position = bounds.position
	node.size = bounds.size
	if not node is BaseButton: node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(node)

func _label(font_size: int, bounds: Rect2, color: Color) -> Label:
	var label = Label.new()
	label.add_theme_font_size_override("font_size",roundi(font_size * Preferences.text_scale()))
	label.add_theme_color_override("font_color",color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(label,bounds)
	return label

func _button(caption: String, bounds: Rect2, action: Callable, node_name: String) -> void:
	var button = Button.new()
	button.text = caption
	button.name = node_name
	button.add_theme_font_size_override("font_size",17)
	_place(button,bounds)
	button.pressed.connect(action)

func _show_chapter() -> void:
	elapsed = 0
	var shot: Dictionary = definition.chapters[chapter]
	heading.text = shot.title
	subtitle.text = shot.text
	chapter_label.text = "%s · %d / %d" % [definition.title,chapter+1,definition.chapters.size()]
	if camera_tween != null: camera_tween.kill()
	if is_instance_valid(transition):
		remove_child(transition)
		transition.queue_free()
	var next_texture = load(shot.get("image","res://assets/cinematics/%s.png" % definition.background))
	if not Preferences.low_quality() and next_texture != backdrop.texture:
		transition = TextureRect.new()
		transition.name = "ChapterDissolve"
		transition.texture = backdrop.texture
		transition.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		transition.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_place(transition,Rect2(backdrop.position,backdrop.size))
		move_child(transition,backdrop.get_index()+1)
	backdrop.texture = next_texture
	backdrop.position = Vector2(-40,-24)
	if not Preferences.low_quality():
		camera_tween = create_tween().set_ignore_time_scale(true).set_parallel(true)
		if is_instance_valid(transition):
			camera_tween.tween_property(transition,"modulate:a",0.0,0.55)
		camera_tween.tween_property(backdrop,"position",Vector2(-64 if chapter%2==0 else -20,-32),float(shot.duration)).set_trans(Tween.TRANS_SINE)
		for label in [heading,subtitle]:
			label.modulate.a = 0
			camera_tween.tween_property(label,"modulate:a",1.0,0.4)
	if paused and camera_tween != null: camera_tween.pause()

func _process(delta: float) -> void:
	if ended or paused: return
	var real_delta = delta/maxf(0.01,Engine.time_scale)
	elapsed += real_delta
	total_elapsed += real_delta
	progress.value = minf(1,elapsed/float(definition.chapters[chapter].duration))
	if not Preferences.low_quality(): queue_redraw()
	if progress.value >= 1: advance()

func _draw() -> void:
	if Preferences.low_quality(): return
	for i in range(26):
		var x = fmod(i*197.0+sin(total_elapsed*0.3+i)*25,1280)
		var y = 538-fmod(i*47.0+total_elapsed*(9+i%4),460)
		var glow = accent
		glow.a = (0.15+0.15*sin(total_elapsed+i))*Preferences.flashes()
		draw_circle(Vector2(x,y),3.0,Color(glow,glow.a*0.2))
		draw_circle(Vector2(x,y),1.0,glow)

func advance() -> void:
	if ended: return
	chapter += 1
	if chapter >= definition.chapters.size(): finish()
	else: _show_chapter()

func toggle_pause() -> void:
	paused = not paused
	get_node("PauseCinematic").text = "Reanudar" if paused else "Pausar"
	if camera_tween != null:
		if paused: camera_tween.pause()
		else: camera_tween.play()

func finish() -> void:
	if ended: return
	ended = true
	# A sequence can open its next clip synchronously when finished is emitted.
	name = "FinishedCinematic"
	finished.emit()
	queue_free()

func _input(event: InputEvent) -> void:
	if ended: return
	var accept = event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE,KEY_ENTER]
	var cancel = event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE
	var pause_key = event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P
	if event is InputEventJoypadButton and event.pressed:
		accept = event.button_index == JOY_BUTTON_A
		cancel = event.button_index == JOY_BUTTON_B
	if accept or cancel or pause_key:
		get_viewport().set_input_as_handled()
		if cancel: finish()
		elif pause_key: toggle_pause()
		else: advance()
