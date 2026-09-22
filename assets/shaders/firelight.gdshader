shader_type canvas_item;
// UV follows sprite mirroring, so the lit side always faces the central fire.
uniform float phase = 0.0;
uniform float strength = 0.26;
varying vec4 actor_tint;
void vertex() {
	actor_tint = COLOR;
}
void fragment() {
	vec4 base = texture(TEXTURE, UV) * actor_tint;
	float pulse = 0.62 + 0.23 * sin(TIME * 6.1) + 0.10 * sin(TIME * 10.7 + phase) + 0.05 * sin(TIME * 17.3);
	float facing_fire = 0.18 + 0.82 * smoothstep(0.12, 0.95, UV.x);
	float moving_light = 0.85 + 0.15 * sin(UV.y * 8.0 - TIME * 3.2 + phase);
	vec3 warmth = vec3(1.0, 0.48, 0.12) * strength * pulse * facing_fire * moving_light;
	COLOR = vec4(base.rgb + warmth * (0.35 + base.rgb * 0.65), base.a);
}
