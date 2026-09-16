shader_type canvas_item;

// Keep the metal rim and transparency intact. Only the inner energy flows.
void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec2 p = (UV - vec2(0.5)) * 2.0;
	float radius = length(p);
	float mask = (1.0 - smoothstep(0.48, 0.66, radius)) * base.a;
	float wave = sin(p.x * 17.0 + sin(p.y * 9.0 - TIME * 2.3) * 2.0 + TIME);
	float flame = pow(max(0.0, wave), 5.0);
	float rise = 0.5 + 0.5 * sin(p.y * 21.0 + TIME * 3.8 + p.x * 6.0);
	vec3 light = vec3(0.07, 0.55, 0.85) * flame * (0.12 + rise * 0.32);
	COLOR = vec4(base.rgb + light * mask, base.a);
}
