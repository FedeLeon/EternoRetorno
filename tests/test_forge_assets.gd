extends SceneTree
const Gear = preload("res://src/presentation/hero_equipment.gd")
const HEROES = ["warrior", "guardian", "rogue", "mage", "cleric", "ranger"]
var checks = 0
var failures = 0
func check(value: bool, caption: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: ", caption)
func _initialize() -> void: call_deferred("run_tests")
func run_tests() -> void:
	for hero in HEROES:
		if not OS.get_cmdline_user_args().is_empty() and hero not in OS.get_cmdline_user_args(): continue
		var hashes: Array = []
		var actor = load("res://src/%s_sprite.gd" % hero).new()
		actor.size = Vector2(192, 160)
		root.add_child(actor)
		var original = actor.frames()
		for weapon in range(4):
			for armor in range(4):
				var path = "res://assets/forge/heroes/%s_w%d_a%d.png" % [hero, weapon, armor]
				check(ResourceLoader.exists(path), "atlas " + path)
				if not ResourceLoader.exists(path): continue
				var hash = FileAccess.get_sha256(path)
				check(hash not in hashes, "distinct equipment variant")
				hashes.append(hash)
				var image = load(path).get_image()
				check(image.get_size() == Vector2i(768, 640 if hero == "warrior" else 768), "dimensions")
				check(image.detect_alpha() != Image.ALPHA_NONE, "transparent background")
				actor.sprite.play("attack")
				actor.sprite.frame = 2
				Gear.apply(actor, hero, {"weapon": weapon, "armor": armor})
				check(actor.sprite.animation == "attack" and actor.sprite.frame == 2, "pose retained")
				check(actor.sprite.is_playing(), "animation keeps playing")
				var frames = actor.sprite.sprite_frames
				for animation in original.get_animation_names():
					check(frames.get_frame_count(animation) == original.get_frame_count(animation), "same frame count")
					check(frames.get_animation_speed(animation) == original.get_animation_speed(animation), "same speed")
					check(frames.get_animation_loop(animation) == original.get_animation_loop(animation), "same loop")
					for i in range(frames.get_frame_count(animation)):
						var texture = frames.get_frame_texture(animation, i)
						check(texture.region == original.get_frame_texture(animation, i).region, "same animation region")
						check(not image.get_region(texture.region).is_invisible(), "nonempty frame")
				actor.set_fallen(true)
				check(actor.sprite.frame == 5 and actor.sprite.animation == "death", "fallen pose")
				Gear.apply(actor, hero, {"weapon": weapon, "armor": armor})
				check(not actor.sprite.is_playing() and actor.sprite.frame == 5, "fallen stays paused after gear application")
		await actor.play_once("revive")
		check(not actor.fallen and actor.sprite.animation == "idle", "animated revival finishes")
		await actor.play_once("attack")
		check(actor.sprite.animation == "idle" and actor.sprite.is_playing(), "attack returns to idle")
		await actor.play_once("death")
		check(actor.fallen and not actor.sprite.is_playing(), "death finishes fallen")
		actor.queue_free()
		await process_frame
	print("FORGE ASSETS: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
