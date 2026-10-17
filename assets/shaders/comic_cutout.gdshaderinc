// White paper rim in screen pixels; samples stay inside the current atlas frame.
uniform sampler2D cutout_source : source_color, filter_linear, repeat_disable;
uniform bool cutout_enabled = false;
uniform vec2 cutout_texel = vec2(0.001);
uniform vec4 cutout_region = vec4(0.0, 0.0, 1.0, 1.0);
uniform float cutout_width : hint_range(0.0, 3.0) = 1.25;
uniform vec4 outline_color : source_color = vec4(1.0, 0.99, 0.96, 1.0);
vec4 comic_cutout(vec2 uv, vec2 pixel_step, vec4 ink) {
	if (!cutout_enabled) { return ink; }
	vec2 reach = min(pixel_step * cutout_width, cutout_region.zw * 0.05);
	float edge = 0.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			if (x != 0 || y != 0) {
				vec2 p = uv + vec2(float(x), float(y)) * reach;
				vec2 lo = cutout_region.xy;
				vec2 hi = lo + cutout_region.zw;
				float inside = step(lo.x,p.x)*step(lo.y,p.y)*step(p.x,hi.x)*step(p.y,hi.y);
				edge = max(edge, texture(cutout_source,clamp(p,lo+cutout_texel*0.5,hi-cutout_texel*0.5)).a*inside);
			}
		}
	}
	float rim = smoothstep(0.15, 0.8, edge) * (1.0 - ink.a) * outline_color.a;
	float alpha = ink.a + rim;
	return vec4((ink.rgb * ink.a + outline_color.rgb * rim) / max(alpha, 0.001), alpha);
}
