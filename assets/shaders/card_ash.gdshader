shader_type canvas_item;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
float grain(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
void fragment() {
	vec4 ink = texture(TEXTURE, UV);
	float noise = grain(floor(UV * vec2(65.0, 90.0)));
	float threshold = (1.0 - UV.y) * 0.65 + noise * 0.35;
	float edge = threshold - progress * 1.08;
	float visible = smoothstep(0.0, 0.035, edge);
	float ember = (1.0 - smoothstep(0.035, 0.11, edge)) * step(0.001, progress);
	ink.rgb = mix(ink.rgb, mix(vec3(0.24, 0.22, 0.21), vec3(1.0, 0.52, 0.15), noise), ember);
	COLOR = vec4(ink.rgb, ink.a * visible);
}
