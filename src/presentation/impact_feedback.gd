extends RefCounted
static func play(ui: Control, target: Control, event: Dictionary) -> void:
	var absorbed = int(event.get("absorbed",0))
	var lost = int(event.get("lost",event.get("damage",0)))
	var pierced: bool = event.get("pierce",false)
	ui.audio.play_sfx("pierce" if pierced else "shield_impact" if absorbed>0 else "flesh_impact")
	var strength = float(preload("res://src/presentation/preferences.gd").settings.get("impact_strength",0.65))
	if strength > 0:
		preload("res://src/presentation/impact_burst.gd").play(ui.layer,target,event)
		var original = target.position
		var recoil = target.create_tween()
		recoil.tween_property(target,"position:x",original.x + (5 if absorbed>0 and lost==0 else 11)*strength,0.055)
		recoil.tween_property(target,"position",original,0.13).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		ui.flash_hit(target)
	var blocked = lost == 0 and absorbed > 0
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
	var center = target.get_global_rect().get_center().x
	ui.rect(label,clampf(center-120,8,1032),target.global_position.y+45,240,56)
	if blocked or pierced:
		var caption = Label.new()
		caption.text = "BLOQUEO" if blocked else "PENETRANTE"
		caption.add_theme_font_size_override("font_size",17)
		caption.add_theme_constant_override("outline_size",4)
		caption.add_theme_color_override("font_outline_color",Color("100b12"))
		caption.add_theme_color_override("font_color",label.get_theme_color("font_color"))
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.position = Vector2(0,52); caption.size = Vector2(240,24)
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_child(caption)
	var tween=label.create_tween().set_parallel(true)
	tween.tween_property(label,"position:y",label.position.y-38,0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label,"modulate:a",0.0,0.5).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)
	if strength > 0 and int(event.get("damage",0))>=16 and preload("res://src/presentation/preferences.gd").settings.get("hit_pause",true):
		# Freeze the target pose only; music and the rest of the arena keep running.
		var processing=target.is_processing()
		target.set_process(false)
		await ui.get_tree().create_timer(0.065*strength).timeout
		if is_instance_valid(target): target.set_process(processing)
