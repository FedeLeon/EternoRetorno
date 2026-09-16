extends RefCounted
# Presentation-only halo. Caller decides eligibility with the existing rules.
static func attach(actor: Control, eligible: bool) -> void:
	if not eligible:
		return
	var glow = ColorRect.new()
	glow.name = "TargetGlow"
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.position = Vector2(-10, actor.size.y - 146)
	glow.size = Vector2(actor.size.x + 20, 156)
	var material = ShaderMaterial.new()
	material.shader = preload("res://assets/ui/shaders/target_glow.gdshader")
	glow.material = material
	actor.add_child(glow)
	actor.move_child(glow, 0)
