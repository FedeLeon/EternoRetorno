extends RefCounted
static var settings: Dictionary = {}
static func speed() -> float: return clampf(float(settings.get("combat_speed", 1.0)), 1.0, 2.0)
static func cutins() -> bool: return not settings.get("reduce_cutins", false)
static func flashes() -> float: return clampf(float(settings.get("flash_intensity", 0.6)), 0.0, 1.0)
static func low_quality() -> bool: return settings.get("low_effects", false)
static func text_scale() -> float: return clampf(float(settings.get("text_scale", 1.0)), 1.0, 1.12)
