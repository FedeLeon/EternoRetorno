shader_type canvas_item;
void fragment() {
	vec2 step_uv = TEXTURE_PIXEL_SIZE * 22.0;
	float halo = 0.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			halo = max(halo, texture(TEXTURE, clamp(UV + vec2(float(x), float(y)) * step_uv, vec2(0.0), vec2(1.0))).a);
		}
	}
	float core = texture(TEXTURE, UV).a;
	float pulse = 0.72 + 0.15 * sin(TIME * 2.0);
	COLOR = vec4(0.95, 0.68, 0.3, max(halo - core, 0.0) * pulse);
}
