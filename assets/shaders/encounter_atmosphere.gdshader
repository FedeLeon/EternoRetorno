shader_type canvas_item;
// Local effects only: the environment stays still and the UI is drawn above it.
uniform int encounter_kind = 0;
uniform vec2 focus = vec2(0.5, 0.38);
uniform vec2 radius = vec2(0.11, 0.04);
uniform vec3 effect_color = vec3(-1.0);

void fragment() {
	vec2 uv = UV;
	vec2 local = (uv - focus) / radius;
	float distance = length(local);
	float mask = 1.0 - smoothstep(0.65, 1.0, distance);
	if (encounter_kind == 0) {
		uv.x += sin(local.y * 18.0 + TIME * 1.4) * 0.0012 * mask;
		uv.y += sin(local.x * 12.0 - TIME * 1.1) * 0.0010 * mask;
	}
	vec4 base = texture(TEXTURE, uv);
	vec3 tint = encounter_kind == 0 ? vec3(0.15, 0.85, 0.7) : (encounter_kind == 1 ? vec3(0.95, 0.18, 0.35) : vec3(0.8, 0.63, 0.3));
	if (effect_color.x >= 0.0) { tint = effect_color; }
	float light = 0.0;
	if (encounter_kind == 0) {
		light = pow(max(0.0, sin(distance * 24.0 - TIME * 1.8)), 10.0) * mask * 0.065;
	} else {
		light = max(0.0, 1.0 - distance) * (0.035 + 0.025 * sin(TIME * (1.8 - float(encounter_kind) * 0.3)));
	}
	vec2 pixel = floor(UV * vec2(1280.0, 720.0));
	for (int i = 0; i < 14; i++) {
		float n = float(i);
		float age = fract(TIME * (0.065 + n * 0.002) + n * 0.173);
		vec2 origin = focus * vec2(1280.0, 720.0);
		float spread = encounter_kind == 2 ? 180.0 : 82.0;
		vec2 particle = origin + vec2(sin(n * 7.13) * spread + sin(age * 6.0 + n) * 12.0, -18.0 - age * 140.0);
		vec2 delta = abs(pixel - floor(particle));
		float side = encounter_kind == 2 ? 1.8 : 1.2;
		float mote = (1.0 - step(side, max(delta.x, delta.y))) * sin(age * 3.14159);
		light += mote * 0.38;
	}
	COLOR = vec4(clamp(base.rgb + tint * light, 0.0, 1.0), base.a);
}
