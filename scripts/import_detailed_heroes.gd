extends SceneTree
# Slices generated poses, normalizes one shared scale per hero and anchors feet.
const HEROES = ["warrior","guardian","rogue","mage","cleric","ranger"]
const ACTIONS = ["idle","attack","skill","guard","hurt","death","run"]
func row_edges(image: Image) -> Array:
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
func column_edges(image: Image, top: int, bottom: int) -> Array:
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
func opaque_bottom(image: Image) -> int:
	for y in range(image.get_height()-1,-1,-1):
		for x in range(image.get_width()):
			if image.get_pixel(x,y).a>0.5:return y+1
	return image.get_height()
func foot_center(image: Image) -> float:
	var sum_x=0.0;var count=0
	for y in range(maxi(0,image.get_height()-12),image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x,y).a>0.5:sum_x+=x;count+=1
	return sum_x/maxi(1,count) if count>0 else image.get_width()/2.0
func _initialize() -> void:
	var metrics: Dictionary = {}
	for hero in HEROES:
		var poses: Dictionary = {}
		var widest = 1; var tallest = 1; var idle_height = 1
		for action in ACTIONS:
			var path = "res://docs/combat_depth_2026_10/sources/%s_%s.png" % [hero,action]
			if not FileAccess.file_exists(path): push_error("Missing sheet: " + path); quit(1); return
			var source = Image.load_from_file(path)
			var rows = row_edges(source)
			var columns = []
			for row in range(3):columns.append(column_edges(source,rows[row],rows[row+1]))
			poses[action] = []
			for i in range(12):
				var start = Vector2i(columns[i/4][i%4],rows[i/4])
				var end = Vector2i(columns[i/4][i%4+1],rows[i/4+1])
				var cell = source.get_region(Rect2i(start,end-start))
				var area = bounds(cell)
				if area.size.x <= 0 or area.size.y <= 0: push_error("Empty pose: " + path + str(i));quit(1);return
				poses[action].append(cell.get_region(area))
				widest = maxi(widest,area.size.x); tallest = maxi(tallest,area.size.y)
				if action == "idle": idle_height = maxi(idle_height,area.size.y)
		var ratio = minf(224.0/widest, minf(232.0/tallest, 204.0/idle_height))
		metrics[hero] = {"idle_height":idle_height * ratio * 0.5, "frames":12}
		for action in ACTIONS:
			var atlas = Image.create(1024,768,false,Image.FORMAT_RGBA8);atlas.fill(Color.TRANSPARENT)
			for i in range(12):
				var cell: Image = poses[action][i]
				var anchor = foot_center(cell) * ratio
				cell.resize(maxi(1,roundi(cell.get_width()*ratio)),maxi(1,roundi(cell.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
				atlas.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),Vector2i((i%4)*256+clampi(roundi(128-anchor),0,256-cell.get_width()),(i/4)*256+240-opaque_bottom(cell)))
			atlas.save_png("res://assets/heroes/detail/%s_%s.png" % [hero,action])
		print("Detailed hero: ",hero," · 84 drawn frames")
	var file = FileAccess.open("res://data/detailed_heroes.json",FileAccess.WRITE);file.store_string(JSON.stringify(metrics,"\t")+"\n")
	quit()
