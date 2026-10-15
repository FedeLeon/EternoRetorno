extends SceneTree
const Actor=preload("res://src/presentation/detailed_hero.gd")
var checks=0;var failures=0
func check(ok: bool,caption: String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",caption)
func _initialize():call_deferred("run_tests")
func run_tests():
	var fixture = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	fixture.fill(Color.TRANSPARENT)
	fixture.fill_rect(Rect2i(10, 40, 50, 55), Color.WHITE)
	fixture.fill_rect(Rect2i(10, 0, 5, 5), Color.WHITE)
	check(preload("res://scripts/sketchbook_sheet_packer.gd").principal_bounds(fixture) == Rect2i(10, 40, 50, 55), "pose crop excludes detached fragments from previous row")
	root.size=Vector2i(1280,720)
	var scene=Control.new();root.add_child(scene)
	var background=ColorRect.new();background.color=Color("15171f");background.size=Vector2(1280,720);scene.add_child(background)
	var heroes=["warrior","guardian","rogue","mage"]
	var actors: Array=[]
	for i in range(heroes.size()):
		var actor=Actor.new();actor.hero_id=heroes[i];actor.size=Vector2(180,150)
		actor.position=Vector2(95+(i%3)*398,120+(i/3)*300);scene.add_child(actor)
		preload("res://src/ui/components/combat_actor_scale.gd").hero(actor,heroes[i]);actors.append(actor)
		var label=Label.new();label.text=heroes[i];label.position=actor.position+Vector2(30,160);scene.add_child(label)
		for action in Actor.ACTIONS:
			check(actor.sprite.sprite_frames.get_frame_count(action)==12,heroes[i]+" twelve "+action+" poses")
			for frame in range(12):
				var texture=actor.sprite.sprite_frames.get_frame_texture(action,frame)
				check(texture.get_size()==Vector2(256,256),"256px frame")
				var image=texture.get_image();if image.is_compressed():image.decompress()
				check(image.get_used_rect().size.x>20,"nonempty drawn pose")
				var bottom=preload("res://src/presentation/hero_grounding.gd").bottom(texture)
				check(bottom>=238 and bottom<=241,"%s %s frame %d grounded at %d" % [heroes[i],action,frame,bottom])
		for weapon in range(4):
			for armor in range(4):
				actor.apply_gear({"weapon":weapon,"armor":armor})
				check(actor.sprite.material.get_shader_parameter("weapon_rank")==float(weapon) and actor.sprite.material.get_shader_parameter("armor_rank")==float(armor),"independent gear ranks")
		actor.apply_gear({"weapon":0,"armor":0})
	await create_timer(0.2).timeout
	for actor in actors:
		check(actor.sprite.frame == 0 and not actor.sprite.is_playing(), "battle idle holds a stable pose")
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat-depth/six-detailed-heroes.png"))
	for action in ["attack","guard","hurt","skill"]:
		for actor in actors:
			actor.sprite.play(action);actor.sprite.frame=6;actor.sprite.pause()
		await process_frame
		if DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("combat-depth/heroes-"+action+".png"))
	for actor in actors:
		actor.play_once("attack")
	await create_timer(0.08).timeout
	for actor in actors:
		actor.play_once("guard")
	await create_timer(0.08).timeout
	for actor in actors:
		actor.play_once("run")
	await create_timer(0.75).timeout
	for actor in actors:
		check(actor.sprite.animation == "run" and actor.sprite.is_playing(), "interrupted attack/guard cannot overwrite running")
		actor.play_once("idle")
		check(actor.sprite.frame == 0 and not actor.sprite.is_playing(), "explicit idle restores stable pose")
	for actor in actors:
		actor.set_fallen(true);check(actor.sprite.frame==11 and actor.fallen,"final defeat pose")
		actor.set_fallen(false);check(actor.sprite.animation=="idle" and not actor.fallen,"idle restored")
	scene.queue_free();await process_frame;Actor.cache.clear()
	print("DETAILED HEROES: %d checks / %d failures"%[checks,failures]);quit(1 if failures else 0)
