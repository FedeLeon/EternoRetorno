extends SceneTree
const Import = preload("res://scripts/enemy_art_import.gd")
func _initialize() -> void:
	for id in ["crypt_bandit","beast_6","flying_1","flying_6","crypt_wolf","bandit_7"]:
		var source = "res://docs/whole_game_polish/sources/"+id
		var motion = "res://docs/whole_game_polish/normalized/"+id+"_motion.png"
		if not complete_cells(motion):
			push_error("Clipped pose in motion source: "+id);quit(1);return
		if not Import.motion(motion,"res://assets/enemies/animations/"+id+".png"):
			push_error("Invalid motion source: "+id);quit(1);return
		if not Import.cutin(source+"_cutin.png","res://assets/comic/enemies/"+id+".png"):
			push_error("Invalid cut-in source: "+id);quit(1);return
	print("Six additional enemy atlases and cut-ins packed")
	quit()

func complete_cells(path: String) -> bool:
	var image = Image.load_from_file(path)
	if image == null: return false
	if image.get_width()%4 != 0 or image.get_height()%2 != 0:
		image.resize(ceili(image.get_width()/4.0)*4,ceili(image.get_height()/2.0)*2,Image.INTERPOLATE_NEAREST)
	var cell_size = image.get_size()/Vector2i(4,2)
	for index in range(8):
		var cell = image.get_region(Rect2i(Vector2i(index%4,index/4)*cell_size,cell_size))
		var bounds = Import.opaque_bounds(cell)
		if bounds.size == Vector2i.ZERO or bounds.position.x < 8 or bounds.position.y < 8 or bounds.end.x > cell_size.x-8 or bounds.end.y > cell_size.y-8:
			return false
	return true
