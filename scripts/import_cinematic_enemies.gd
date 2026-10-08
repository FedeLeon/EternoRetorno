extends SceneTree
const Import = preload("res://scripts/enemy_art_import.gd")
func _initialize() -> void:
 for id in ["elemental_3","beast_3","elemental_4","bandit_6","bandit_4","flying_5"]:
  var source = "res://docs/enemies/cinematic_expansion/sources/"+id
  if not Import.motion(source+"_motion.png","res://assets/enemies/animations/"+id+".png"): quit(1);return
  if not Import.cutin(source+"_cutin.png","res://assets/comic/enemies/"+id+".png"): quit(1);return
 print("Six enemy motion atlases and cut-ins packed")
 quit()
