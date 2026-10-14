shader_type canvas_item;
render_mode unshaded;
float oval(vec2 p, vec2 center, vec2 radius) {
	return 1.0 - smoothstep(0.65, 1.0, length((p - center) / radius));
}
void fragment() {
	vec2 p = UV;
	// Small displacement only on the distant lake and side treetops.
	float trees = max(oval(p, vec2(0.055, 0.22), vec2(0.09, 0.24)),
		oval(p, vec2(0.955, 0.20), vec2(0.065, 0.23)));
	float lake = oval(p, vec2(0.63, 0.26), vec2(0.13, 0.045));
	vec2 shift = vec2(sin(TIME * 0.85 + p.y * 21.0) * 0.0007 * trees, 0.0);
	shift.x += sin(p.y * 560.0 + TIME * 1.1) * 0.00045 * lake;
	vec4 painted = texture(TEXTURE, clamp(p + shift, vec2(0.0), vec2(1.0)));
	float fire = oval(p, vec2(0.5, 0.61), vec2(0.095, 0.055));
	painted.rgb += vec3(0.036, 0.016, 0.003) * fire * (0.8 + 0.2 * sin(TIME * 3.4));
	COLOR = painted;
}
