extends SceneTree
## Rebuild compatible classic/forge atlases from the newly authored action drawings.
const Pack=preload("res://scripts/sketchbook_sheet_packer.gd")
const BASE_HEIGHT={"warrior":78.0,"guardian":91.0,"rogue":87.0,"mage":90.0}
const ROWS={"warrior":["idle","attack","skill","hurt","death"],"guardian":["idle","attack","skill","guard","hurt","death"],"rogue":["idle","attack","skill","guard","hurt","death"],"mage":["idle","attack","skill","guard","hurt","death"]}
var manifest:Dictionary
func _initialize() -> void:
	var file="res://docs/art_direction/postapocalyptic/assets.json"
	manifest=JSON.parse_string(FileAccess.get_file_as_string(file))
	var forge:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/forge_visuals.json"))
	for hero in ROWS:
		var source="assets/heroes/detail/%s_idle.png"%hero
		if manifest.get(source,{}).get("comic_rebuild_revision",0)!=1:continue
		var idle=Image.load_from_file("res://"+source)
		var first=idle.get_region(Rect2i(0,0,256,256))
		var ratio=BASE_HEIGHT[hero]/Pack.bounds(first,0.5).size.y
		var frames:Array[Image]=[]
		var complete=true
		for action in ROWS[hero]:
			var path="assets/heroes/detail/%s_%s.png"%[hero,action]
			if manifest.get(path,{}).get("comic_rebuild_revision",0)!=1:complete=false;break
			var image=Image.load_from_file("res://"+path)
			for index in [0,2,4,6,8,11]:
				var pose=image.get_region(Rect2i((index%4)*256,(index/4)*256,256,256))
				frames.append(pose.get_region(Pack.bounds(pose)))
		if not complete:continue
		var sheet=Pack.pack(frames,6,128,ratio,120)
		store(sheet,"assets/%s/%s-128.png"%[hero,hero],source)
		var height=Pack.bounds(sheet.get_region(Rect2i(0,0,128,128)),0.5).size.y
		for weapon in range(4):
			for armor in range(4):
				var key="%s_w%d_a%d"%[hero,weapon,armor]
				# New drawings remain civilian; upgrades never paste equipment over the body.
				var variant=sheet.duplicate()
				for y in range(variant.get_height()):
					for x in range(variant.get_width()):
						var pixel=variant.get_pixel(x,y)
						if pixel.a>0.5 and pixel.s<0.22 and pixel.v>0.15 and pixel.v<0.75:
							pixel.r=minf(1,pixel.r+weapon*0.018)
							pixel.b=minf(1,pixel.b+armor*0.018)
							variant.set_pixel(x,y,pixel)
				store(variant,"assets/forge/heroes/%s.png"%key,source)
				forge[key]=height
		var portrait="assets/heroes/identity/portraits/%s.png"%hero
		if manifest.get(portrait,{}).get("comic_rebuild_revision",0)==1:
			var image=Image.load_from_file("res://"+portrait)
			store(image,"assets/cinematics/portraits/%s.png"%hero,portrait)
	var ready=true
	var portraits=Image.create(512,128,false,Image.FORMAT_RGBA8);portraits.fill(Color.TRANSPARENT)
	var index=0
	for hero in ROWS:
		var path="assets/heroes/identity/portraits/%s.png"%hero
		if manifest.get(path,{}).get("comic_rebuild_revision",0)!=1:ready=false;break
		var image=Image.load_from_file("res://"+path)
		var side=mini(image.get_width(),image.get_height())
		var crop=image.get_region(Rect2i((image.get_width()-side)/2,0,side,side))
		crop.resize(128,128,Image.INTERPOLATE_LANCZOS)
		portraits.blit_rect(crop,Rect2i(0,0,128,128),Vector2i(index*128,0));index+=1
	if ready:store(portraits,"assets/camp/front-128.png","assets/heroes/identity/portraits/warrior.png")
	FileAccess.open(file,FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	FileAccess.open("res://data/forge_visuals.json",FileAccess.WRITE).store_string(JSON.stringify(forge,"\t")+"\n")
	quit()
func store(image:Image,path:String,source:String) -> void:
	Pack.save(image,"res://"+path)
	manifest[path]={"source":source,"source_sha256":FileAccess.get_sha256("res://"+source),"sha256":FileAccess.get_sha256("res://"+path),"style":"postapocalyptic_comic","comic_rebuild_revision":1,"processing":"compatible layout derived from newly authored comic actions, tiny material rank tint"}
