extends RefCounted
# Resolve both legacy atlas icons and individual transparent relic assets.
static func texture(relic: Dictionary) -> Texture2D:
	if relic.get("asset", "") != "": return load(relic.asset)
	if relic.get("texture") != null: return relic.texture
	if relic.get("icon_path", "") != "": return load(relic.icon_path)
	var icon = int(relic.get("icon", 0))
	var atlas = AtlasTexture.new()
	atlas.atlas = preload("res://assets/objects/icons.png")
	atlas.region = Rect2((icon % 4) * 64, (icon / 4) * 64, 64, 64)
	return atlas
