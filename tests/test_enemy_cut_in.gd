extends SceneTree
const CutIn = preload("res://src/presentation/enemy_cut_in.gd")
const Game = preload("res://src/game.gd")
var failures = 0
func _initialize() -> void: call_deferred("run_tests")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr(message)
func run_tests() -> void:
	root.size = Vector2i(1280, 720)
	var host = Control.new()
	root.add_child(host)
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg = TextureRect.new()
	bg.texture = preload("res://assets/dungeon/combat.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	host.add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var catalog = preload("res://src/enemy_sprite.gd").entries()
	for visual in catalog:
		var effect = CutIn.play(host, visual)
		effect._process(0.001)
		var initial = effect.picture.position.x
		await create_timer(0.25).timeout
		check(effect.picture.texture != null and effect.from_right, "texture and direction " + visual)
		check(effect.picture.position.x < initial, "entry moves left " + visual)
		check(is_equal_approx(effect.picture.position.x + effect.picture.size.x, host.size.x * 0.985), "right anchor " + visual)
		check(effect.picture.texture.get_image().detect_alpha() != Image.ALPHA_NONE, "transparent " + visual)
		if catalog[visual].get("foreground_frames",1) == 4:
			check(effect.frame_grid == Vector2i(2,2), "four drawn attack poses " + visual)
			var atlas = effect.frame_texture.atlas.get_image()
			if atlas.is_compressed(): atlas.decompress()
			var cell = atlas.get_size()/2
			var hashes = []
			for frame in range(4):
				var pose = atlas.get_region(Rect2i(Vector2i(frame%2,frame/2)*cell,cell))
				check(pose.get_used_rect().size.x > 20 and pose.detect_alpha() != Image.ALPHA_NONE,"drawn transparent pose %s/%d" % [visual,frame])
				var digest = hash(pose.get_data())
				check(digest not in hashes,"distinct attack pose %s/%d" % [visual,frame])
				hashes.append(digest)
		if DisplayServer.get_name() != "headless" and visual == "crypt_lancer":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat/enemy-comic.png"))
		await effect.finished
		await process_frame
		check(not is_instance_valid(effect), "effect removed")
	check(CutIn.play(host, "unknown") == null, "unknown ID ignored")
	var game = Game.new("user://unused-enemy-cut-in.save", false)
	game.new_run(["warrior", "guardian"], 42)
	game.enter_node(0)
	game._start_combat(["rat", "skeleton"])
	game.run.combat.enemies[0].poison = 999
	game.run.combat.enemies[1].intent = {"damage": 0, "block": 5, "target": 0}
	game.end_turn()
	check(game.resolved_enemy_attacks.is_empty(), "poison death and block-only have no attacks")
	game._start_combat(["rat", "skeleton"])
	for hero in game.run.heroes: hero.hp = 1
	game.run.combat.enemies[0].intent = {"damage": 999, "all": true, "target": 0}
	game.end_turn()
	check(game.resolved_enemy_attacks == [0], "no phantom second attack after defeat")
	print("ENEMY COMIC FAILURES: ", failures)
	quit(1 if failures else 0)
