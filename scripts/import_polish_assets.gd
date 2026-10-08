extends SceneTree
# Mechanical slicing/resizing of ImageGen artwork; no generated poses in code.
const Sheets = preload("res://scripts/sprite_sheet_tools.gd")
func _initialize() -> void:
	var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string("res://docs/polish_2026_10/jobs.json"))
	var metrics: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/detailed_heroes.json"))
	var manifest: Array = []
	for job_index in range(jobs.size()):
		var job: Dictionary=jobs[job_index]
		# Equipment overlays were retired; keep original sheets as provenance only.
		if job.kind == "equipment": continue
		var path="res://docs/polish_2026_10/sources/%s.png" % job.id
		if not FileAccess.file_exists(path): continue
		var source=Image.load_from_file(path)
		if job.kind=="card":
			source.resize(448,288,Image.INTERPOLATE_LANCZOS)
			var target="res://assets/cards/art/%s.png" % job.id
			source.save_png(target);manifest.append({"source":path,"target":target})
		elif job.kind=="action":
			var poses: Array=[]
			var rows=Sheets.row_edges(source)
			for row in range(3):
				var columns=Sheets.column_edges(source,rows[row],rows[row+1])
				for column in range(4):
					var cell=source.get_region(Rect2i(columns[column],rows[row],columns[column+1]-columns[column],rows[row+1]-rows[row]))
					var area=Sheets.bounds(cell)
					if area.size.x<=0 or area.size.y<=0: push_error("Empty pose "+job.id);quit(1);return
					poses.append(cell.get_region(area))
			var first: Image=poses[0]
			var ratio=float(metrics[job.hero].idle_height)*2.0/first.get_height()
			for pose in poses: ratio=minf(ratio,minf(352.0/pose.get_width(),352.0/pose.get_height()))
			var atlas=Image.create(1536,1152,false,Image.FORMAT_RGBA8);atlas.fill(Color.TRANSPARENT)
			for i in range(12):
				var cell: Image=poses[i]
				var anchor=Sheets.foot_center(cell)*ratio
				cell.resize(maxi(1,roundi(cell.get_width()*ratio)),maxi(1,roundi(cell.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
				atlas.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),Vector2i((i%4)*384+clampi(roundi(192-anchor),0,384-cell.get_width()),(i/4)*384+368-Sheets.opaque_bottom(cell)))
			var target="res://assets/heroes/actions/%s.png" % job.id
			atlas.save_png(target);manifest.append({"source":path,"target":target,"frames":12,"cell":384,"foot":368,"ratio":ratio})
		elif job.kind == "boss":
			var columns = 4
			var relic_ids: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/boss_relics.json"))
			var floor_number=["boss_crypt","boss_forest","boss_fire"].find(job.id)+1
			var ids: Array=relic_ids.keys().filter(func(id):return int(relic_ids[id].floor)==floor_number)
			for i in range(3): # Fourth source cell was the replaced objective illustration.
				var cell=source.get_region(Rect2i((i%columns)*source.get_width()/columns,0,source.get_width()/columns,source.get_height()))
				var bounds=Sheets.bounds(cell)
				if bounds.size.x<=0 or bounds.size.y<=0: push_error("Empty item "+job.id);quit(1);return
				cell=cell.get_region(bounds)
				var ratio=minf(232.0/cell.get_width(),232.0/cell.get_height())
				cell.resize(maxi(1,roundi(cell.get_width()*ratio)),maxi(1,roundi(cell.get_height()*ratio)),Image.INTERPOLATE_LANCZOS)
				var icon=Image.create(256,256,false,Image.FORMAT_RGBA8);icon.fill(Color.TRANSPARENT)
				icon.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),(Vector2i(256,256)-cell.get_size())/2)
				var target="res://assets/relics/boss/%s.png" % ids[i]
				icon.save_png(target);manifest.append({"source":path,"target":target,"cell":256})
	var file=FileAccess.open("res://docs/polish_2026_10/assets.json",FileAccess.WRITE);file.store_string(JSON.stringify(manifest,"\t")+"\n")
	print("Polish artwork: ",manifest.size()," assets imported")
	quit()
