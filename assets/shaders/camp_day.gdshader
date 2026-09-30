shader_type canvas_item;
render_mode unshaded;
uniform sampler2D built_ground : source_color, filter_linear;
// Market, expeditions, forge, church; supplied from the camp snapshot.
uniform vec4 built_plots = vec4(0.0);
float plot_region(vec2 pixel, vec4 bounds) {
	vec2 edge = min(pixel - bounds.xy, bounds.zw - pixel);
	return smoothstep(0.0, 12.0, min(edge.x, edge.y));
}
// Masks are tied to the original daytime painting, in normalized coordinates.
float oval(vec2 uv, vec2 center, vec2 radius) {
	return 1.0 - smoothstep(0.65, 1.0, length((uv - center) / radius));
}
void fragment() {
	vec2 p = UV;
	vec4 base = texture(TEXTURE, p);
	float foliage = max(oval(p, vec2(0.045, 0.12), vec2(0.16, 0.24)),
		oval(p, vec2(0.95, 0.155), vec2(0.15, 0.19)));
	foliage *= smoothstep(0.01, 0.08, base.g - base.b);
	float lake = oval(p, vec2(0.565, 0.324), vec2(0.17, 0.058));
	lake *= smoothstep(0.04, 0.16, base.b - base.r);
	float falls = oval(p, vec2(0.230, 0.232), vec2(0.023, 0.092));
	falls *= smoothstep(0.02, 0.13, base.b - base.r);
	float breeze = sin(TIME * 1.15 + p.y * 16.0) + 0.3 * sin(TIME * 2.1 + p.x * 29.0);
	vec2 offset = vec2(breeze * 0.0011, sin(TIME * 1.5 + p.x * 22.0) * 0.0005) * foliage;
	offset += vec2(sin(p.y * 650.0 + TIME * 1.9) * 0.00075,
		sin(p.x * 220.0 + TIME * 1.3) * 0.00035) * lake;
	offset.y += sin(p.y * 160.0 - TIME * 4.5) * 0.0013 * falls;
	vec4 painted = texture(TEXTURE, clamp(p + offset, vec2(0.0), vec2(1.0)));
	painted.rgb += vec3(0.025, 0.036, 0.043) * lake * sin(p.y * 450.0 + TIME * 1.7);
	vec2 pixel = p * vec2(1280.0, 720.0);
	float cleared = max(
		max(built_plots.x * plot_region(pixel, vec4(90.0, 260.0, 426.0, 348.0)),
			built_plots.y * plot_region(pixel, vec4(416.0, 463.0, 858.0, 604.0))),
		max(built_plots.z * plot_region(pixel, vec4(40.0, 378.0, 436.0, 518.0)),
			built_plots.w * plot_region(pixel, vec4(874.0, 420.0, 1298.0, 585.0))));
	painted = mix(painted, texture(built_ground, p), cleared);
	COLOR = painted;
}
