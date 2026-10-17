shader_type canvas_item;
#include "res://assets/shaders/comic_cutout.gdshaderinc"
varying vec4 vertex_tint;
void vertex() { vertex_tint = COLOR; }
void fragment() {
	vec2 sample_uv = cutout_enabled ? clamp(UV, cutout_region.xy + cutout_texel * 0.5, cutout_region.xy + cutout_region.zw - cutout_texel * 0.5) : UV;
	COLOR = comic_cutout(UV, fwidth(UV), texture(TEXTURE, sample_uv)) * vertex_tint;
}
