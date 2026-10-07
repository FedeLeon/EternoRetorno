extends RefCounted
# Local particles follow the actor; never a full-screen flash or combat rule.
static func play(actor: Control, action: String, hero: String) -> void:
	if preload("res://src/presentation/preferences.gd").flashes() <= 0: return
	var colors={"warrior":Color("a658f2"),"guardian":Color("f1c875"),"rogue":Color("94d842"),"mage":Color("7dabff"),"cleric":Color("ffe8a6"),"ranger":Color("8bd1ef")}
	var color: Color=colors.get(hero,Color.WHITE)
	var particles=CPUParticles2D.new()
	particles.amount=8 if action=="hurt" or preload("res://src/presentation/preferences.gd").low_quality() else 16
	particles.one_shot=true;particles.lifetime=0.4;particles.explosiveness=0.85
	particles.position=Vector2(actor.size.x*0.7,actor.size.y-58)
	particles.direction=Vector2(-1,0) if action in ["guard","hurt"] else Vector2(1,-0.2)
	particles.spread=40;particles.initial_velocity_min=22;particles.initial_velocity_max=64
	particles.gravity=Vector2(0,42);particles.scale_amount_min=0.7;particles.scale_amount_max=1.5
	particles.color=color
	actor.add_child(particles);particles.emitting=true
	var tween=actor.create_tween();tween.tween_interval(0.6);tween.tween_callback(particles.queue_free)
