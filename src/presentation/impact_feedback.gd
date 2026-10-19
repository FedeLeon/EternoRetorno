extends RefCounted
static func play(ui: Control, target: Control, event: Dictionary) -> void:
	var absorbed = int(event.get("absorbed",0))
	var lost = int(event.get("lost",event.get("damage",0)))
	var pierced: bool = event.get("pierce",false)
	var hero_id = ""
	var enemy_id = ""
	var enemy_target = false
	for owner in ui.hero_art:
		if ui.hero_art[owner] == target: hero_id = ui.game.run.party[owner]
	for index in ui.enemy_art:
		if ui.enemy_art[index] == target:
			enemy_target = true
			enemy_id = target.get_meta("battle_enemy_id", "")
	preload("res://src/audio/battle_audio.gd").impact(ui.audio, event, hero_id, enemy_id)
	var blocked = lost == 0 and absorbed > 0
	if target.has_method("play_once"): target.play_once("guard" if blocked else "hurt")
	if enemy_target:
		preload("res://src/presentation/hit_slash.gd").play(ui.layer, target, int(event.get("hit_index", 0)), blocked)
	var label = Label.new(); label.text = str(absorbed) if blocked else "0" if lost == 0 else "-%d" % lost
	label.name = "FloatingDamage"
	label.add_theme_font_size_override("font_size",40)
	label.add_theme_constant_override("outline_size",6)
	label.add_theme_color_override("font_outline_color",Color("100b12"))
	label.add_theme_color_override("font_shadow_color",Color(0,0,0,0.9))
	label.add_theme_constant_override("shadow_offset_x",2)
	label.add_theme_constant_override("shadow_offset_y",3)
	label.add_theme_color_override("font_color",Color("d3efff") if blocked else Color("ffe0a3") if pierced else Color("ffd0ca"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter=Control.MOUSE_FILTER_IGNORE;label.z_index=90
	var origin = number_origin(ui.layer, target)
	ui.rect(label,origin.x,origin.y,104,56)
	if blocked or pierced:
		var caption = Label.new()
		caption.text = "BLOQUEO" if blocked else "PENETRANTE"
		caption.add_theme_font_size_override("font_size",17)
		caption.add_theme_constant_override("outline_size",4)
		caption.add_theme_color_override("font_outline_color",Color("100b12"))
		caption.add_theme_color_override("font_color",label.get_theme_color("font_color"))
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.position = Vector2(0,52); caption.size = Vector2(104,24)
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_child(caption)
	var tween=label.create_tween().set_parallel(true)
	tween.tween_property(label,"position:y",label.position.y-38,0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label,"modulate:a",0.0,0.5).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)

static func number_origin(layer: Control, target: Control) -> Vector2:
	var body = target.body_rect() if target.has_method("body_rect") else Rect2(Vector2.ZERO,target.size)
	body = layer.get_global_transform().affine_inverse() * (target.get_global_transform() * body)
	return Vector2(clampf(body.end.x-72,8,1168),clampf(body.position.y+body.size.y*.48-28,164,maxf(164,body.end.y-96)))
