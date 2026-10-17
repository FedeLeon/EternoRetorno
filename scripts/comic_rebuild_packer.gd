extends RefCounted
## Geometric conversion only; every drawing comes from its recorded ImageGen source.
const Pack = preload("res://scripts/sketchbook_sheet_packer.gd")
const BODY_HEIGHT = {"warrior":183.0,"guardian":188.0,"rogue":203.0,"mage":182.0}

static func fit(source: Image, dimensions: Vector2i, transparent: bool, margin: int = 4, align_top: bool = false) -> Image:
	var image = source.duplicate()
	image.convert(Image.FORMAT_RGBA8)
	if not transparent:
		var aspect=float(dimensions.x)/dimensions.y
		var crop=Vector2i(mini(image.get_width(),roundi(image.get_height()*aspect)),mini(image.get_height(),roundi(image.get_width()/aspect)))
		var origin=(image.get_size()-crop)/2
		if align_top:origin.y=0
		image=image.get_region(Rect2i(origin,crop))
		image.resize(dimensions.x,dimensions.y,Image.INTERPOLATE_LANCZOS)
		return image
	var bounds = Pack.bounds(image)
	if bounds.size == Vector2i.ZERO: return null
	image = image.get_region(bounds)
	var factor = minf(float(dimensions.x-margin*2)/image.get_width(),float(dimensions.y-margin*2)/image.get_height())
	image.resize(maxi(1,roundi(image.get_width()*factor)),maxi(1,roundi(image.get_height()*factor)),Image.INTERPOLATE_LANCZOS)
	var result = Image.create(dimensions.x,dimensions.y,false,Image.FORMAT_RGBA8);result.fill(Color.TRANSPARENT)
	result.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),(dimensions-image.get_size())/2)
	return result

static func actor(poses: Array[Image], columns: int, cell: int, baseline: int, target_height: float = 0, foot_anchor: bool = false) -> Image:
	var extent = Vector2.ZERO
	for pose in poses: extent = extent.max(Vector2(pose.get_size()))
	var ratio = minf(float(cell-(12 if cell<=128 else 28))/extent.x,float(cell-(12 if cell<=128 else 28))/extent.y)
	if target_height>0: ratio = minf(ratio,target_height/poses[0].get_height())
	if not foot_anchor: return Pack.pack(poses,columns,cell,ratio,baseline)
	var image=Image.create(columns*cell,ceili(float(poses.size())/columns)*cell,false,Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for i in range(poses.size()):
		var pose=poses[i].duplicate()
		pose.resize(maxi(1,roundi(pose.get_width()*ratio)),maxi(1,roundi(pose.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
		var bottom=Pack.bottom(pose)
		var band=pose.get_region(Rect2i(0,maxi(0,bottom-20),pose.get_width(),mini(20,bottom)))
		var boots=Pack.bounds(band,0.5)
		var x=clampi(cell/2-boots.position.x-boots.size.x/2,4,maxi(4,cell-pose.get_width()-4))
		image.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),Vector2i((i%columns)*cell+x,(i/columns)*cell+baseline-bottom))
	return image

static func process(job: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var source = Image.load_from_file("res://"+job.source)
	if source==null: return result
	if job.transparent and source.detect_alpha()==Image.ALPHA_NONE: push_error("Opaque cutout rejected: "+job.id);return result
	source.convert(Image.FORMAT_RGBA8)
	match job.kind:
		"direct":
			for target in job.targets:
				var image = fit(source,Vector2i(target.dimensions[0],target.dimensions[1]),job.transparent,4,job.id=="title__background")
				if image!=null: result[target.path]=image
		"hero_sheet":
			var poses = Pack.actor_cells("res://"+job.source,job.columns,job.rows)
			if poses.size()!=int(job.frames): return result
			if job.action in ["run","run8"]:
				# Limit accidental scale drift between authored gait poses, offline only.
				var heights:Array[int]=[]
				for pose in poses:heights.append(Pack.bounds(pose,0.5).size.y)
				heights.sort()
				var middle=heights.size()/2
				var median=(heights[middle-1]+heights[middle])*0.5
				for pose in poses:
					var height=float(Pack.bounds(pose,0.5).size.y)
					var ratio=clampf(height,median*0.96,median*1.04)/height
					pose.resize(roundi(pose.get_width()*ratio),roundi(pose.get_height()*ratio),Image.INTERPOLATE_LANCZOS)
			var target: Dictionary = job.targets[0]
			var large = job.action in ["thrust","sweep","charged"]
			var cell = 128 if job.action=="run8" else 384 if large else 256
			var baseline = 120 if cell==128 else 368 if large else 240
			var columns = 8 if job.action=="run8" else int(job.columns)
			result[target.path]=actor(poses,columns,cell,baseline,BODY_HEIGHT[job.hero]*(0.5 if cell==128 else 1.0),job.action in ["idle","guard24"])
		"machine_bank":
			var poses = Pack.actor_cells("res://"+job.source,4,4)
			if poses.size()!=16:return result
			for row in range(4):
				var id: String = job.machines[row]
				var path = "assets/enemies/animations/%s.png"%id
				if not job.targets.any(func(t):return t.path==path):continue
				var frames: Array[Image] = []
				for index in [0,0,0,0,1,1,2,3]: frames.append(poses[row*4+index])
				var sheet = actor(frames,8,256,240)
				result[path]=sheet
				result["assets/enemies/hd/%s.png"%id]=sheet.get_region(Rect2i(0,0,256,256))
		"enemy_sheet":
			var poses = Pack.actor_cells("res://"+job.source,4,2)
			if poses.size()!=8:return result
			var sheet = actor(poses,8,256,240)
			result["assets/enemies/animations/%s.png"%job.enemy]=sheet
			result["assets/enemies/hd/%s.png"%job.enemy]=sheet.get_region(Rect2i(0,0,256,256))
		"enemy_foreground_bank", "icon_bank":
			var poses = Pack.cells("res://"+job.source,job.columns,job.rows)
			# Empty trailing icon cells are deliberately unused; extract them individually.
			if poses.size()<job.targets.size():
				poses=[]
				var cell = source.get_size()/Vector2i(job.columns,job.rows)
				for i in range(job.targets.size()):
					poses.append(source.get_region(Rect2i(Vector2i((i%int(job.columns))*cell.x,(i/int(job.columns))*cell.y),cell)))
			for i in range(job.targets.size()):
				var target:Dictionary=job.targets[i]
				result[target.path]=fit(poses[i],Vector2i(target.dimensions[0],target.dimensions[1]),true,6)
		"card_bank":
			var cell = source.get_size()/Vector2i(6,4)
			for i in range(job.targets.size()):
				var tile=source.get_region(Rect2i(Vector2i((i%6)*cell.x,(i/6)*cell.y),cell))
				var low=tile.get_size();var high=Vector2i(-1,-1)
				for y in range(tile.get_height()):
					for x in range(tile.get_width()):
						var color=tile.get_pixel(x,y)
						if color.v>0.34 or (color.v>0.21 and color.s>0.38):
							low=low.min(Vector2i(x,y));high=high.max(Vector2i(x,y))
				var area=Rect2i(low,high-low+Vector2i.ONE).grow(3).intersection(Rect2i(Vector2i.ZERO,tile.get_size())) if high.x>=0 else Rect2i(Vector2i.ZERO,tile.get_size())
				var drawing=tile.get_region(area)
				var dimensions=Vector2i(job.targets[i].dimensions[0],job.targets[i].dimensions[1])
				var factor=minf(float(dimensions.x-28)/drawing.get_width(),float(dimensions.y-20)/drawing.get_height())
				drawing.resize(maxi(1,roundi(drawing.get_width()*factor)),maxi(1,roundi(drawing.get_height()*factor)),Image.INTERPOLATE_LANCZOS)
				var picture=Image.create(dimensions.x,dimensions.y,false,Image.FORMAT_RGBA8);picture.fill(tile.get_pixel(2,2))
				picture.blit_rect(drawing,Rect2i(Vector2i.ZERO,drawing.get_size()),(picture.get_size()-drawing.get_size())/2)
				result[job.targets[i].path]=picture
		"animal_sheet":
			var poses=Pack.actor_cells("res://"+job.source,4,2)
			if poses.size()!=8:return result
			result[job.targets[0].path]=actor(poses,4,192,174)
		"objects_atlas","chest_atlas","numbers":
			var poses=Pack.cells("res://"+job.source,job.columns,job.rows)
			if poses.size()!=int(job.columns)*int(job.rows):return result
			if job.kind=="numbers":
				for i in range(10):
					var glyph=fit(poses[i],Vector2i(32,36),true,1) # Equal cap height, including narrow 1.
					var used=Pack.bounds(glyph,0.5)
					var aligned=Image.create(32,48,false,Image.FORMAT_RGBA8);aligned.fill(Color.TRANSPARENT)
					aligned.blit_rect(glyph,Rect2i(Vector2i.ZERO,glyph.get_size()),Vector2i(0,46-used.end.y))
					result["assets/ui/numbers/%d.png"%i]=aligned
			else:
				result[job.targets[0].path]=actor(poses,4 if job.kind=="objects_atlas" else 6,64 if job.kind=="objects_atlas" else 256,56 if job.kind=="objects_atlas" else 248)
		"fire_bank":
			var poses=Pack.actor_cells("res://"+job.source,6,4)
			if poses.size()!=24:return result
			for target in job.targets:
				result[target.path]=actor(poses if target.dimensions[0]>512 else poses.slice(0,4),6 if target.dimensions[0]>512 else 4,256 if target.dimensions[0]>512 else 128,248 if target.dimensions[0]>512 else 124)
	return result
