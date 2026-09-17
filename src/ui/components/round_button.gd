extends Button
# Ignore transparent corners when clicking the circular medallion.
func _has_point(point: Vector2) -> bool:
	return point.distance_to(size / 2.0) <= minf(size.x, size.y) / 2.0
