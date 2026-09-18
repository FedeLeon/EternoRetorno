shader_type canvas_item;
uniform float sweep = -1.0;
void fragment() {
	float mask = texture(TEXTURE, UV).a;
	float band = 1.0 - smoothstep(0.025, 0.15, abs(UV.x + UV.y * 0.38 - sweep));
	COLOR = vec4(1.0, 0.96, 0.83, mask * band * 0.22);
}
