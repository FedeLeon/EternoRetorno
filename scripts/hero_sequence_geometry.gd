extends RefCounted
## Shared offline geometry: isolate authored figures and locate their boot contacts.
static func figures(image: Image) -> Array:
	# Connected figures can cross nominal grid gutters when a weapon is raised.
	var width = image.get_width()
	var height = image.get_height()
	var seen = PackedByteArray()
	seen.resize(width * height)
	var result: Array = []
	for y in height:
		for x in width:
			var start = y * width + x
			if seen[start] or image.get_pixel(x,y).a < .2: continue
			var queue: Array[int] = [start]
			seen[start] = 1
			var low = Vector2i(x,y)
			var high = low
			var cursor = 0
			while cursor < queue.size():
				var point = queue[cursor]
				cursor += 1
				var pos = Vector2i(point % width, point / width)
				low = low.min(pos)
				high = high.max(pos)
				for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					var n = pos + d
					if n.x < 0 or n.y < 0 or n.x >= width or n.y >= height: continue
					var index = n.y * width + n.x
					if seen[index] or image.get_pixelv(n).a < .2: continue
					seen[index] = 1
					queue.append(index)
			if queue.size() > 3000: result.append({"bounds":Rect2i(low,high-low+Vector2i.ONE),"pixels":queue})
	result.sort_custom(func(a,b):
		var row_a = int(a.bounds.get_center().y*4/height)
		var row_b = int(b.bounds.get_center().y*4/height)
		return a.bounds.position.x < b.bounds.position.x if row_a == row_b else row_a < row_b)
	return result

static func feet(image: Image, silhouette: bool = false) -> Vector2:
	var spans: Array = []
	var start = -1
	var last_ink = -1
	for x in image.get_width()+1:
		var boot = false
		if x < image.get_width():
			for y in range(maxi(0,image.get_height()-maxi(30,roundi(image.get_height()*.14))),image.get_height()):
				var c = image.get_pixel(x,y)
				if c.a > .6 and (silhouette or (c.r > .16 and c.r > c.g*1.12 and c.g > c.b*1.05)):
					boot = true
					break
		if boot and start < 0: start = x
		if boot: last_ink = x
		if start >= 0 and (x-last_ink > 4 or x == image.get_width()):
			if last_ink-start >= 8: spans.append(Vector2(start,last_ink+1))
			start = -1
	if spans.size() < 2: return Vector2.ZERO
	spans.sort_custom(func(a,b):return a.y-a.x > b.y-b.x)
	var a: float = (spans[0].x+spans[0].y)*.5
	var b: float = (spans[1].x+spans[1].y)*.5
	return Vector2(minf(a,b),maxf(a,b))
