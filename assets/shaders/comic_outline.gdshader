shader_type canvas_item;
uniform float width : hint_range(0.0, 6.0) = 2.5;
uniform vec4 outline_color : source_color = vec4(1.0, 0.99, 0.95, 1.0);
varying vec4 vertex_tint;
void vertex() {
	vertex_tint = COLOR;
}
void fragment() {
	vec4 ink = texture(TEXTURE, UV);
	float edge = 0.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			edge = max(edge, texture(TEXTURE, UV + vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE * width).a);
		}
	}
	float rim = smoothstep(0.2, 0.7, edge) * (1.0 - ink.a);
	float alpha = ink.a + rim;
	COLOR = vec4((ink.rgb * ink.a + outline_color.rgb * rim) / max(alpha, 0.001), alpha) * vertex_tint;
}
