extends SceneTree
const Enemy = preload("res://src/enemy_sprite.gd")
var checks=0
var failures=0
func _initialize(): call_deferred("verify")
func check(ok: bool, message: String):
 checks+=1
 if not ok: failures+=1;printerr("FAIL: ",message)
func verify():
 root.size=Vector2i(1280,720)
 var stage=Control.new();root.add_child(stage)
 var metrics=JSON.parse_string(FileAccess.get_file_as_string("res://data/enemy_pose_sizes.json"))
 var shown=["beast_2","elemental_2","skeleton_1","flying_0","goblin_3","flying_3"]
 var actors=[]
 var index=0
 for id in metrics:
  var actor=Enemy.new();actor.visual_id=id;actor.size=Vector2(128,132)
  actor.position=Vector2(40+index%6*207,250+index/6*190);stage.add_child(actor)
  actor.set_process(false)
  check(FileAccess.get_sha256("res://assets/enemies/animations/%s.png"%id)==metrics[id].sha256,"metrics match original atlas")
  var parent_scale=actor.scale;var base=actor.base_scale
  actor.acting=true
  for frame in range(4,8):
   actor.sprite.frame=frame;actor._size_pose()
   var factor=float(metrics[id].scale[frame])
   check(factor>=1 and factor<=1.3,"conservative correction never shrinks artwork")
   check(actor.sprite.scale.is_equal_approx(Vector2.ONE*base*factor) and actor.scale==parent_scale,"only inner pose scale is corrected")
   var bottom=float(metrics[id].bottom[frame])
   var foot=(bottom-64+actor.sprite.offset.y)*actor.sprite.scale.y
   check(absf(foot-(bottom-128)*base)<0.001,"opaque ground baseline preserved")
  actor.acting=false;actor._size_pose()
  check(actor.sprite.scale.is_equal_approx(Vector2.ONE*base*float(metrics[id].scale[7])),"frame correction survives leaving action state")
  actor.sprite.frame=0;actor._size_pose()
  check(actor.sprite.scale==Vector2.ONE*base and actor.sprite.offset.y==-64,"idle restores normal scale and offset")
  actor.queue_free();index+=1
 await process_frame
 for i in range(shown.size()):
  var actor=Enemy.new();actor.visual_id=shown[i];actor.size=Vector2(128,132);actor.position=Vector2(50+i*207,170);stage.add_child(actor)
  actor.scale=Vector2.ONE*1.5;actors.append(actor)
  var label=Label.new();label.text=shown[i];label.position=Vector2(30+i*207,330);stage.add_child(label)
 await create_timer(.15).timeout
 if DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("enemy-size/idle.png"))
 for actor in actors: actor.play_once("attack")
 await create_timer(.16).timeout
 for actor in actors: check(actor.acting and actor.sprite.frame>=4,"drawn attack reaches corrected pose")
 if DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("enemy-size/attack.png"))
 await create_timer(.35).timeout
 for actor in actors:
  check(not actor.acting and actor.sprite.frame<4 and actor.sprite.scale==Vector2.ONE*actor.base_scale,"actual tween returns to idle frame and normal size together")
 # Elementals and other small attack poses must keep their geometry
 # when frozen by a reaction or death, including an immediate follow-up hit.
 for actor in actors: actor.queue_free()
 await process_frame
 for id in ["elemental_2","beast_2","flying_0"]:
  var actor=Enemy.new();actor.visual_id=id;actor.size=Vector2(128,132);actor.position=Vector2(500,170);stage.add_child(actor)
  actor.set_process(false);actor.scale=Vector2.ONE*1.8125
  actor.acting=true;actor.sprite.frame=5;actor._size_pose()
  var pose_scale=actor.sprite.scale;var pose_offset=actor.sprite.offset;var outer_scale=actor.scale
  actor.acting=false
  if DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("enemy-size/"+id+"-before-hurt.png"))
  actor.play_once("hurt")
  check(actor.sprite.scale==pose_scale and actor.sprite.offset==pose_offset and actor.scale==outer_scale,"hurt preserves drawn size and feet "+id)
  await create_timer(.25).timeout
  check(not actor.acting and actor.sprite.scale==pose_scale,"hurt completion preserves drawn size "+id)
  if DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("enemy-size/"+id+"-after-hurt.png"))
  actor.play_once("death")
  await create_timer(.08).timeout
  check(actor.acting and actor.sprite.scale==pose_scale and actor.sprite.offset==pose_offset and actor.scale==outer_scale,"ash begins at full pose size "+id)
  if DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(preload("res://tests/artifacts.gd").path("enemy-size/"+id+"-ash-start.png"))
  await create_timer(1.3).timeout
  check(actor.fallen and not actor.sprite.visible,"death hides dissolved enemy "+id)
  actor.set_fallen(false)
  check(actor.sprite.visible and actor.sprite.frame==0 and actor.sprite.scale==Vector2.ONE*actor.base_scale and actor.scale==outer_scale,"revival restores idle size "+id)
  actor.queue_free()
 stage.queue_free();await process_frame
 print("ENEMY POSE SIZES: %d checks / %d failures"%[checks,failures]);quit(1 if failures else 0)
