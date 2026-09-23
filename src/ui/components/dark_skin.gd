extends RefCounted
# Shared gothic chrome. Artwork and geometry only; never gameplay or persistence.
const ACCENT = Color("b6adbf")

static func frame(compact: bool = false, tint: Color = Color.WHITE) -> StyleBoxTexture:
 var style = StyleBoxTexture.new()
 style.texture = load("res://assets/ui/dark/button.png" if compact else "res://assets/ui/dark/panel.png")
 style.modulate_color = tint
 # Sample from the metal perimeter, omitting the black padding outside it.
 # Normalized coordinates also work with the configured import size limit.
 var crop = Rect2(0.022, 0.105, 0.956, 0.765) if compact else Rect2(0.014, 0.016, 0.972, 0.949)
 var texture_size = style.texture.get_size()
 style.region_rect = Rect2(crop.position * texture_size, crop.size * texture_size)
 for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
  style.set_texture_margin(side, (6 if side in [SIDE_TOP, SIDE_BOTTOM] else 24) if compact else 32)
  style.set_content_margin(side, 12 if side in [SIDE_LEFT, SIDE_RIGHT] else 8)
 style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
 style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
 return style

static func button(tint: Color = Color.WHITE) -> StyleBoxTexture:
 return trim("button_trim", tint)

static func dialog() -> StyleBoxTexture:
 return trim("dialog_trim", Color.WHITE)

static func trim(asset: String, tint: Color) -> StyleBoxTexture:
 var style = StyleBoxTexture.new()
 style.texture = load("res://assets/ui/dark/%s.svg" % asset)
 style.modulate_color = tint
 for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
  style.set_texture_margin(side, 10)
  style.set_content_margin(side, 14 if side in [SIDE_LEFT, SIDE_RIGHT] else (6 if asset == "button_trim" else 12))
 return style

static func focus() -> StyleBoxFlat:
 var style = StyleBoxFlat.new()
 style.bg_color = Color.TRANSPARENT
 style.border_color = ACCENT
 style.set_border_width_all(1)
 style.set_corner_radius_all(3)
 return style
