extends SceneTree
const Grounding = preload("res://src/presentation/hero_grounding.gd")
var checks = 0
var failures = 0
func _initialize(): call_deferred("run_tests")
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		printerr(message)
func run_tests():
	for hero in ["warrior", "guardian", "rogue", "mage"]:
		var actor = load("res://src/%s_sprite.gd" % hero).new()
		root.add_child(actor)
		for gear in [{}, {"weapon":0,"armor":0}, {"weapon":3,"armor":3}]:
			preload("res://src/presentation/hero_equipment.gd").apply(actor, hero, gear)
			var sprite = actor.sprite
			var frames = sprite.sprite_frames
			var baseline = Grounding.bottom(frames.get_frame_texture("idle", 0))
			for animation in frames.get_animation_names():
				if animation in ["idle", "run", "death", "revive"]: continue
				sprite.animation = animation
				for index in range(frames.get_frame_count(animation)):
					sprite.frame = index
					check(Grounding.bottom(frames.get_frame_texture(animation, index)) + sprite.offset.y == baseline, hero + " " + animation + " remains grounded")
			for animation in ["idle", "run", "death", "revive"]:
				sprite.animation = animation
				check(sprite.offset.y == 0, hero + " resets offset for " + animation)
		actor.free()
	print("HERO GROUNDING: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
