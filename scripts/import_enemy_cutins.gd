extends SceneTree
## Offline import of two isolated machine illustrations per model. No runtime atlas.
const BASE = "res://art_sources/enemy_cutins_2026_10_19/"
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
func read_json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))
func write_json(path: String, data: Variant) -> void:
	FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(data,"\t",false)+"\n")
func _initialize():
	var jobs:Array=read_json(BASE+"jobs.json")
	var visuals:Dictionary=read_json("res://data/enemy_visuals.json")
	var manifest:Dictionary=read_json("res://art_sources/art_direction/postapocalyptic/assets.json")
	var comic:Dictionary=read_json("res://data/comic_art.json")
	var report:Array=[]
	for job in jobs:
		var source=Image.load_from_file("res://"+job.source)
		if source==null or source.detect_alpha()==Image.ALPHA_NONE or job.parts.size()!=2:
			push_error("Expected isolated transparent machine attack/defense source: "+job.visual);quit(1);return
		source.convert(Image.FORMAT_RGBA8)
		var poses:Array[Image]=[];var extent=Vector2i.ZERO
		for part in job.parts:
			var pose=component(source,part);pose.fix_alpha_edges();poses.append(pose);extent=extent.max(pose.get_size())
		var factor=minf(1.0,minf(736.0/extent.x,480.0/extent.y))
		var paths:Dictionary={}
		for i in range(2):
			var action:String=["attack","defense"][i]
			var pose:Image=poses[i]
			if factor<1.0:pose.resize(maxi(1,roundi(pose.get_width()*factor)),maxi(1,roundi(pose.get_height()*factor)),Image.INTERPOLATE_LANCZOS)
			var bounds=Pack.bounds(pose,.5)
			var frame=Image.create(768,512,false,Image.FORMAT_RGBA8);frame.fill(Color.TRANSPARENT)
			var offset=Vector2i(384-bounds.position.x-bounds.size.x/2,256-bounds.position.y-bounds.size.y/2)
			frame.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),offset);frame.fix_alpha_edges()
			var target="assets/comic/enemies/%s/%s.png"%[action,job.visual]
			DirAccess.make_dir_recursive_absolute("res://"+target.get_base_dir());Pack.save(frame,"res://"+target)
			paths[action]="res://"+target
			manifest[target]={"sha256":FileAccess.get_sha256("res://"+target),"source":job.source,"source_sha256":job.source_sha256,"style":"postapocalyptic_comic","tool":"image_gen.imagegen","enemy_cut_in_revision":1,"outline_baked":true,"visual":job.visual,"action":action,"source_part":job.parts[i],"common_downscale":factor,"generation":"art_sources/enemy_cutins_2026_10_19/jobs/%s.json"%job.visual,"inputs_sha256":{job.reference:job.reference_sha256},"processing":"One authored machine only; connected silhouette + antialias fringe; proportional reduction only; centered 768x512 static cut-in, independent attack/defense"}
			comic.baked[target]=true
			report.append({"visual":job.visual,"action":action,"path":target,"common_downscale":factor,"bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]})
		visuals[job.visual].foreground=paths
		print("ENEMY CUTINS: ",job.visual," attack + defense")
	write_json("res://data/enemy_visuals.json",visuals)
	write_json("res://data/comic_art.json",comic)
	write_json("res://art_sources/art_direction/postapocalyptic/assets.json",manifest)
	write_json("res://artifacts/enemy_cutins_review/import.json",report)
	print("ENEMY CUTINS: ",report.size()," independent machine illustrations")
	quit()
func component(source:Image,part:Dictionary)->Image:
	var b:Array=part.bounds
	var rect=Rect2i(int(b[0]),int(b[1]),int(b[2]),int(b[3])).grow(2).intersection(Rect2i(Vector2i.ZERO,source.get_size()))
	var image=source.get_region(rect);var bytes=image.get_data();var width=image.get_width();var height=image.get_height()
	var seen=PackedByteArray();seen.resize(width*height)
	var mask=PackedByteArray();mask.resize(width*height)
	var seed=Vector2i(int(part.seed[0]),int(part.seed[1]))-rect.position
	var pending:Array[int]=[seed.y*width+seed.x];seen[pending[0]]=1
	while not pending.is_empty():
		var key:int=pending.pop_back();mask[key]=1
		var point=Vector2i(key%width,key/width)
		for delta in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next:Vector2i=point+delta
			if next.x<0 or next.y<0 or next.x>=width or next.y>=height:continue
			var index=next.y*width+next.x
			if seen[index]:continue
			seen[index]=1
			if bytes[index*4+3]>51:pending.append(index)
	var output=PackedByteArray();output.resize(bytes.size())
	for y in range(height):
		for x in range(width):
			var key=y*width+x;var selected=mask[key]==1
			if not selected and bytes[key*4+3]>0:
				for dy in range(-1,2):
					for dx in range(-1,2):
						var px=x+dx;var py=y+dy
						if px>=0 and py>=0 and px<width and py<height and mask[py*width+px]==1:selected=true
			if selected:
				for channel in range(4):output[key*4+channel]=bytes[key*4+channel]
	return Image.create_from_data(width,height,false,Image.FORMAT_RGBA8,output)
