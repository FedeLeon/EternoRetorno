shader_type canvas_item;
#include "res://assets/shaders/comic_cutout.gdshaderinc"
varying vec4 tint;
void vertex() { tint = COLOR; }
uniform vec4 frame_rect = vec4(0.0, 0.0, 1.0, 1.0);
uniform float phase = 0.0;
uniform float enabled = 0.0;
uniform float clock = 0.0;
void fragment() {
	vec2 p = (UV - frame_rect.xy) / frame_rect.zw;
	// Only peripheral cloth and hands move. Head, chest and planted feet stay fixed.
	float feet = 1.0 - smoothstep(0.76, 0.88, p.y);
	float below_head = smoothstep(0.24, 0.36, p.y);
	float cape = (1.0 - smoothstep(0.30, 0.44, p.x)) * below_head * feet;
	float hand = smoothstep(0.57, 0.72, p.x) * below_head * feet;
	vec2 offset = vec2(sin(clock * 1.7 + p.y * 7.0 + phase) * cape * 0.009,
		sin(clock * 1.25 + phase) * hand * 0.006);
	vec2 sample_uv = frame_rect.xy + clamp(p + offset * enabled, vec2(0.001), vec2(0.999)) * frame_rect.zw;
	vec2 shifted_uv = mix(UV, sample_uv, enabled);
	COLOR = tint * comic_cutout(shifted_uv, fwidth(UV), texture(TEXTURE, shifted_uv));
}
