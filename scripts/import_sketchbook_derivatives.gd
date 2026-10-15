extends SceneTree
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
var manifest: Dictionary = {}
func _initialize() -> void:
	var manifest_path = "res://docs/art_direction/postapocalyptic/assets.json"
	if FileAccess.file_exists(manifest_path): manifest = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var portraits = Image.create(512,128,false,Image.FORMAT_RGBA8)
	portraits.fill(Color.TRANSPARENT)
	var ids = ["warrior","guardian","rogue","mage"]
	for index in range(ids.size()):
		var source = "res://assets/heroes/identity/portraits/%s.png" % ids[index]
		var image = Image.new();image.load_png_from_buffer(FileAccess.get_file_as_bytes(source))
		image.convert(Image.FORMAT_RGBA8)
		# Central face/torso from the already approved small-card portrait.
		var side = mini(image.get_width(),image.get_height())
		var face = image.get_region(Rect2i((image.get_width()-side)/2,0,side,side))
		face.resize(128,128,Image.INTERPOLATE_LANCZOS)
		portraits.blit_rect(face,Rect2i(0,0,128,128),Vector2i(index*128,0))
		store(image,"assets/cinematics/portraits/%s.png" % ids[index],source,"approved portrait fallback")
	store(portraits,"assets/camp/front-128.png","res://assets/heroes/identity/portraits","four approved faces, central square crops")
	var fire = "res://assets/base_camp/dusk/fire.png"
	var flame = Image.new();flame.load_png_from_buffer(FileAccess.get_file_as_bytes(fire))
	store(flame,"assets/camp/fire-natural.png",fire,"reuse approved 24-frame pencil fire")
	FileAccess.open(manifest_path,FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	quit()
func store(image: Image, target: String, source: String, processing: String) -> void:
	Pack.save(image,"res://"+target)
	manifest[target] = {"sha256":FileAccess.get_sha256("res://"+target),"source":source.trim_prefix("res://"),"processing":processing}
