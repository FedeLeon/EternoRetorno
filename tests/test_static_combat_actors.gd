extends SceneTree
const Hero = preload("res://src/presentation/detailed_hero.gd")
const Enemy = preload("res://src/enemy_sprite.gd")
var checks = 0
var failures = 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL: ",message)
func verify() -> void:
	var catalog = preload("res://src/data/json_catalog.gd").dictionary("res://data/static_combat.json")
	var host = Control.new(); root.add_child(host)
	for kind in ["heroes","enemies"]:
		for id in catalog[kind]:
			var actor = Hero.new() if kind=="heroes" else Enemy.new()
			if kind=="heroes": actor.hero_id=id
			else: actor.visual_id=id
			actor.size=Vector2(196,164); host.add_child(actor)
			check(actor.sprite is TextureRect,"body uses a plain illustration: "+id)
			check(not actor.is_processing(),"body has no animation processor: "+id)
			var origin=actor.position;var outer=actor.scale
			var animated = kind=="heroes"
			for action in ["idle","attack","guard","skill","hurt","death"]:
				actor.set_fallen(false)
				actor.begin_action(action)
				check((actor.sprite.texture is AtlasTexture)==animated,"authored sequences for heroes: "+id+"/"+action)
				var texture=actor.sprite.texture;var transform=actor.sprite.get_transform()
				var pixels=hash(texture.get_image().get_data())
				for i in range(2): await process_frame
				if not animated: check(actor.sprite.texture==texture and hash(texture.get_image().get_data())==pixels,"held action never advances drawings")
				check(actor.sprite.get_transform()==transform and actor.position==origin and actor.scale==outer,"no body movement, scale, rotation or recoil")
				check(absf(actor.body_rect().end.y-actor.size.y)<.01,"every action stays planted: "+id+"/"+action)
			check(actor.begin_action("hurt")==-1 and actor.current_action=="death","late damage cannot overwrite death")
			actor.queue_free();await process_frame
	# Delayed completions cannot replace a newer pose or explicit restoration.
	var actor=Hero.new();actor.size=Vector2(196,164);host.add_child(actor)
	actor.play_once("attack");actor.begin_action("guard")
	await create_timer(.4).timeout
	check(actor.current_action=="guard","old attack completion cannot reset newer defense")
	actor.play_once("death");actor.set_fallen(false)
	await create_timer(.4).timeout
	check(not actor.fallen and actor.current_action=="idle","old death completion cannot hide restored hero")
	actor.begin_action("attack");var texture=actor.sprite.texture
	actor.apply_gear({"weapon":3,"armor":2})
	check(actor.sprite.texture==texture and actor.current_action=="attack","gear preserves the selected action")
	check(actor.sprite.material.get_shader_parameter("weapon_rank")==3.0,"static gear still represents progression")
	check(not FileAccess.file_exists("res://data/combat_idle.json"),"retired idle data removed")
	check(not DirAccess.dir_exists_absolute("res://assets/enemies/animations"),"retired machine atlases removed")
	host.queue_free();await process_frame
	print("STATIC ACTORS: %d checks / %d failures"%[checks,failures]);quit(1 if failures else 0)
