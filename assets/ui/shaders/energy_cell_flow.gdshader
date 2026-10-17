shader_type canvas_item;
#include "res://assets/shaders/comic_cutout.gdshaderinc"
varying vec4 comic_tint;
void vertex() { comic_tint = COLOR; }

// Pulse only the cyan side tubes. The metal and number window stay still.
void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float sides = 1.0 - smoothstep(0.08, 0.13, min(UV.x, 1.0 - UV.x));
	float vertical = smoothstep(0.28, 0.36, UV.y) * (1.0 - smoothstep(0.72, 0.8, UV.y));
	float cyan = smoothstep(0.1, 0.35, base.b - base.r);
	float pulse = 0.5 + 0.5 * sin(UV.y * 20.0 - TIME * 2.0);
	base.rgb += vec3(0.02, 0.15, 0.2) * pulse * sides * vertical * cyan;
	COLOR = comic_cutout(UV, fwidth(UV), base) * comic_tint;
}
