extends RefCounted
# Shared transparent-sheet extraction and anchors used only by importers.
static func row_edges(image: Image) -> Array:
	# Generated sheets use three rows, but their gutters are not exact thirds.
	var edges = [0]
	for row in [1,2]:
		var expected = roundi(row*image.get_height()/3.0)
		var radius = roundi(image.get_height()/3.0*0.18)
		var best = expected; var best_count = image.get_width()+1
		for y in range(expected-radius,expected+radius+1):
			var count=0
			for x in range(image.get_width()):
				if image.get_pixel(x,y).a>0.2:count+=1
			if count<best_count or (count==best_count and absi(y-expected)<absi(best-expected)):
				best=y;best_count=count
		edges.append(best)
	edges.append(image.get_height())
	return edges
static func column_edges(image: Image, top: int, bottom: int) -> Array:
	var edges = [0]
	for column in [1,2,3]:
		var expected = roundi(column*image.get_width()/4.0)
		var radius = roundi(image.get_width()/4.0*0.18)
		var best = expected; var best_count = (bottom-top+1)*6
		for x in range(expected-radius,expected+radius+1):
			var count=0
			for y in range(top,bottom):
				# Separate bodies first when a bright projectile bridges two poses.
				if image.get_pixel(x,y).a>0.2:count+=6 if y>top+(bottom-top)*0.65 else 1
			if count<best_count or (count==best_count and absi(x-expected)<absi(best-expected)):
				best=x;best_count=count
		edges.append(best)
	edges.append(image.get_width())
	return edges
static func bounds(image: Image) -> Rect2i:
	var low = image.get_size()
	var high = Vector2i(-1,-1)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x,y).a > 0.2:
				low = low.min(Vector2i(x,y)); high = high.max(Vector2i(x,y))
	return Rect2i(low,high-low+Vector2i.ONE)
static func opaque_bottom(image: Image) -> int:
	for y in range(image.get_height()-1,-1,-1):
		for x in range(image.get_width()):
			if image.get_pixel(x,y).a>0.5:return y+1
	return image.get_height()
static func foot_center(image: Image) -> float:
	var sum_x=0.0;var count=0
	for y in range(maxi(0,image.get_height()-12),image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x,y).a>0.5:sum_x+=x;count+=1
	return sum_x/maxi(1,count) if count>0 else image.get_width()/2.0
