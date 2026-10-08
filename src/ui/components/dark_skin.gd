extends RefCounted
# Shared gothic chrome. Artwork and geometry only; never gameplay or persistence.
const ACCENT = Color("b6adbf")

static func frame(compact: bool = false, tint: Color = Color.WHITE) -> StyleBoxTexture:
 return trim("button" if compact else "panel", tint)

static func button(tint: Color = Color.WHITE) -> StyleBoxTexture:
 return trim("button", tint)

static func dialog() -> StyleBoxTexture:
 return trim("panel", Color.WHITE)

static func trim(asset: String, tint: Color) -> StyleBoxTexture:
 var style = StyleBoxTexture.new()
 style.texture = load("res://assets/ui/polished/%s.svg" % asset)
 style.modulate_color = tint
 for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
  style.set_texture_margin(side, 10)
  style.set_content_margin(side, 14 if side in [SIDE_LEFT, SIDE_RIGHT] else (6 if asset == "button" else 14))
 return style

static func focus() -> StyleBoxFlat:
 var style = StyleBoxFlat.new()
 style.bg_color = Color.TRANSPARENT
 style.border_color = ACCENT
 style.set_border_width_all(1)
 style.set_corner_radius_all(3)
 return style
