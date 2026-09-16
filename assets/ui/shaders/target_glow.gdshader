shader_type canvas_item;
render_mode unshaded;
void fragment() {
	vec2 p = (UV - vec2(0.5)) * 2.0;
	float radius = length(p);
	float haze = (1.0 - smoothstep(0.40, 1.0, radius)) * 0.27;
	float ring = exp(-pow((radius - 0.65) / 0.20, 2.0)) * 0.25;
	float pulse = 0.82 + 0.18 * sin(TIME * 3.5);
	COLOR = vec4(1.0, 0.78, 0.32, (haze + ring) * pulse);
}
