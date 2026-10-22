extends Control
## Visual result only; the battle and its rewards are already committed.
signal finished

static func play(parent: Control) -> void:
	var banner = load("res://src/presentation/victory_announcement.gd").new()
	banner.name = "VictoryAnnouncement"
	parent.add_child(banner)
	await banner.finished
	banner.queue_free()
	await parent.get_tree().process_frame

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_as_relative = false
	z_index = 180
	wordmark("Victory", "res://assets/battle_results/victory.png", Vector2(620,148), -110)
	var knockout = wordmark("Knockout", "res://assets/battle_results/knockout.png", Vector2(300,140), -24)
	# The lower word overlaps the title and floats independently.
	if not preload("res://src/presentation/preferences.gd").low_quality():
		var float_text = create_tween().set_loops(2)
		float_text.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		float_text.tween_property(knockout, "position:y", knockout.position.y - 7, .38)
		float_text.tween_property(knockout, "position:y", knockout.position.y, .38)
	modulate.a = 0
	var fade = create_tween().set_trans(Tween.TRANS_SINE)
	fade.tween_property(self, "modulate:a", 1.0, .16)
	fade.tween_interval(1.2)
	fade.tween_property(self, "modulate:a", 0.0, .25)
	fade.finished.connect(func(): finished.emit())

func wordmark(id: String, path: String, extent: Vector2, top: float) -> TextureRect:
	var picture = TextureRect.new()
	picture.name = id
	picture.texture = load(path)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(picture)
	picture.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	picture.offset_left = -extent.x * .5
	picture.offset_right = extent.x * .5
	picture.offset_top = top
	picture.offset_bottom = top + extent.y
	return picture
