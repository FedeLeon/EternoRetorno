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
static func edges(image: Image, count: int, vertical: bool, start: int = 0, end: int = -1, search: float = 0.12) -> Array[int]:
	var extent = image.get_height() if vertical else image.get_width()
	var other = image.get_width() if vertical else image.get_height()
	if end < 0: end = other
	var output: Array[int] = [0]
	for i in range(1,count):
		var expected = roundi(float(i)*extent/count)
		var radius = roundi(float(extent)/count*search)
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
		cell.convert(Image.FORMAT_RGBA8)
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

# Generated actor banks have uneven gutters. Locate actual separators, then
# crop to the principal connected silhouette instead of including neighbour fragments.
static func actor_cells(source: String, columns: int, rows: int, row_columns: Array = [], row_edges: Array = []) -> Array[Image]:
	var image = Image.load_from_file(source)
	var output: Array[Image] = []
	if image == null: return output
	var ys: Array = row_edges if not row_edges.is_empty() else edges(image, rows, true, 0, -1, 0.35)
	if ys.size() != rows + 1 or int(ys[0]) != 0 or int(ys[-1]) != image.get_height(): return []
	for index in range(rows):
		if int(ys[index]) >= int(ys[index + 1]): return []
	for row in range(rows):
		var count = int(row_columns[row]) if not row_columns.is_empty() else columns
		var xs = edges(image, count, false, ys[row], ys[row + 1], 0.30)
		for column in range(count):
			var cell = image.get_region(Rect2i(xs[column], ys[row], xs[column + 1] - xs[column], ys[row + 1] - ys[row]))
			var area = principal_bounds(cell)
			if area.size == Vector2i.ZERO: return []
			output.append(cell.get_region(area))
	return output

static func principal_bounds(image: Image) -> Rect2i:
	var width = image.get_width()
	var height = image.get_height()
	var visited = PackedByteArray()
	visited.resize(width * height)
	var largest = 0
	var result = Rect2i()
	for y in range(height):
		for x in range(width):
			var index = y * width + x
			if visited[index] or image.get_pixel(x, y).a <= 0.2: continue
			var pending: Array[Vector2i] = [Vector2i(x, y)]
			visited[index] = 1
			var low = Vector2i(x, y)
			var high = low
			var count = 0
			while not pending.is_empty():
				var point = pending.pop_back()
				count += 1
				low = low.min(point)
				high = high.max(point)
				for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					var next = point + offset
					if next.x < 0 or next.x >= width or next.y < 0 or next.y >= height: continue
					var key = next.y * width + next.x
					if visited[key] or image.get_pixelv(next).a <= 0.2: continue
					visited[key] = 1
					pending.append(next)
			if count > largest:
				largest = count
				result = Rect2i(low, high - low + Vector2i.ONE)
	return result
