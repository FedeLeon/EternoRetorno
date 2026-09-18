shader_type canvas_item;
varying vec4 tint;
void vertex() { tint = COLOR; }
uniform float progress = 0.0;
uniform vec4 frame_rect = vec4(0.0, 0.0, 1.0, 1.0);
float grain(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
void fragment() {
	vec2 p = (UV - frame_rect.xy) / frame_rect.zw;
	float noise = grain(floor(p * 90.0));
	float edge = (1.0 - p.y) * 0.65 + noise * 0.35 - progress * 1.08;
	vec4 ink = texture(TEXTURE, UV);
	float ember = (1.0 - smoothstep(0.035, 0.11, edge)) * step(0.001, progress);
	ink.rgb = mix(ink.rgb, mix(vec3(0.24, 0.22, 0.21), vec3(1.0, 0.52, 0.15), noise), ember);
	COLOR = tint * vec4(ink.rgb, ink.a * smoothstep(0.0, 0.035, edge));
}
