extends SceneTree
const Actor=preload("res://src/presentation/detailed_hero.gd")
var checks=0
var failures=0
func check(ok: bool,label: String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run_tests")
func run_tests():
 root.size=Vector2i(1280,720)
 var scene=Control.new();scene.size=Vector2(1280,720);root.add_child(scene)
 var background=TextureRect.new();background.texture=load("res://assets/dungeon/combat.png");background.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;background.size=scene.size;scene.add_child(background)
 var heroes=["warrior","guardian","rogue","mage"]
 var actors=[]
 for i in range(heroes.size()):
  var actor=Actor.new();actor.hero_id=heroes[i];actor.gear={"weapon":i%3+1,"armor":i%3+1};actor.position=Vector2(60+i*200,200);actor.size=Vector2(150,220);scene.add_child(actor);actors.append(actor)
  check(actor.sprite.get_children().filter(func(node):return node is Sprite2D).is_empty(),"no floating equipment on "+heroes[i])
  check(actor.sprite.material.get_shader_parameter("weapon_rank")==float(i%3+1) and actor.sprite.material.get_shader_parameter("armor_rank")==float(i%3+1),"equipment ranks retained "+heroes[i])
  for action in ["thrust","sweep","charged"]:
   var sheet=actor.sprite.sprite_frames
   check(sheet.get_frame_count(action)==12,"twelve timing frames "+heroes[i]+action)
   var texture=sheet.get_frame_texture(action,0)
   check(texture.get_size()==Vector2(384,384),"fixed frame regions preserved")
   # Count authored keys in the PNG; lossy texture import can change held pixels.
   var image=Image.load_from_file(texture.atlas.resource_path);var signatures={}
   for frame in range(12):
    var crop=image.get_region(Rect2i(sheet.get_frame_texture(action,frame).region));signatures[hash(crop.get_data())]=true
    check(crop.get_pixel(0,0).a<0.01,"transparent pose background")
    check(preload("res://scripts/sketchbook_sheet_packer.gd").bottom(crop)==368,"fixed boot baseline "+heroes[i]+action+str(frame))
   check(signatures.size()>=4 and signatures.size()<=5,"four action keyposes with held timing and idle return")
 for action in ["idle","guard"]:
  for actor in actors:actor.sprite.play(action);actor.sprite.pause();actor.sprite.frame=5
  await process_frame
  if DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("polish/motion-"+action+".png"))
 for action in ["thrust","sweep","charged"]:
  for actor in actors:actor.sprite.play(action);actor.sprite.pause();actor.sprite.frame=5
  await process_frame
  if DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("polish/motion-"+action+".png"))
  for actor in actors:
   check(is_equal_approx(actor.sprite.position.y+(384-16)*.5,actor.size.y),"attack shares idle ground anchor")
   check(actor.sprite.get_children().filter(func(node):return node is Sprite2D).is_empty(),"attack artwork has no duplicate equipment")
 scene.queue_free();await process_frame;Actor.cache.clear();await process_frame
 print("POLISH MOTION: ",checks," checks / ",failures," failures");quit(1 if failures else 0)
