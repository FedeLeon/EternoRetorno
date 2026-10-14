extends RefCounted
# Geometric packing only: retain drawn pixels, proportions and a common scale.
static func bounds(image: Image, threshold: float = 0.2) -> Rect2i:
	var low = image.get_size()
	var high = Vector2i(-1,-1)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x,y).a > threshold:
				low = low.min(Vector2i(x,y)); high = high.max(Vector2i(x,y))
	return Rect2i() if high.x < 0 else Rect2i(low,high-low+Vector2i.ONE)
static func bottom(image: Image) -> int:
	var area = bounds(image,0.5)
	return area.end.y
static func edges(image: Image, count: int, vertical: bool, start: int = 0, end: int = -1) -> Array[int]:
	var extent = image.get_height() if vertical else image.get_width()
	var other = image.get_width() if vertical else image.get_height()
	if end < 0: end = other
	var output: Array[int] = [0]
	for i in range(1,count):
		var expected = roundi(float(i)*extent/count)
		var radius = roundi(float(extent)/count*0.12)
		var best = expected
		var least = 1000000
		for position in range(expected-radius,expected+radius+1):
			var ink = 0
			for across in range(start,end):
				var color = image.get_pixel(across,position) if vertical else image.get_pixel(position,across)
				if color.a > 0.2: ink += 1
			if ink < least or (ink == least and absi(position-expected) < absi(best-expected)):
				best = position; least = ink
		output.append(best)
	output.append(extent)
	return output
static func cells(source: String, columns: int, rows: int) -> Array[Image]:
	var image = Image.load_from_file(source)
	var output: Array[Image] = []
	if image == null: return output
	var ys = edges(image,rows,true)
	for row in range(rows):
		var xs = edges(image,columns,false,ys[row],ys[row+1])
		for column in range(columns):
			var cell = image.get_region(Rect2i(xs[column],ys[row],xs[column+1]-xs[column],ys[row+1]-ys[row]))
			var area = bounds(cell)
			if area.size == Vector2i.ZERO: return []
			output.append(cell.get_region(area))
	return output
static func pack(poses: Array[Image], columns: int, size: int, ratio: float, baseline: int) -> Image:
	var rows = ceili(float(poses.size())/columns)
	var atlas = Image.create(columns*size,rows*size,false,Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	for i in range(poses.size()):
		var cell = poses[i].duplicate()
		cell.resize(maxi(1,roundi(cell.get_width()*ratio)),maxi(1,roundi(cell.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
		# Resampling can leave a faint halo below the actual foot. Keep one soft
		# row after the opaque baseline; the sprite still has its full cell size.
		cell = cell.get_region(Rect2i(0,0,cell.get_width(),mini(cell.get_height(),bottom(cell)+1)))
		atlas.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),Vector2i((i%columns)*size+(size-cell.get_width())/2,(i/columns)*size+baseline-bottom(cell)))
	return atlas
static func save(image: Image, path: String) -> void:
	var temporary = path+".pending"
	FileAccess.open(temporary,FileAccess.WRITE).store_buffer(image.save_png_to_buffer())
	DirAccess.rename_absolute(temporary,path)
