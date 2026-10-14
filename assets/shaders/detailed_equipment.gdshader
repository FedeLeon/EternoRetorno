shader_type canvas_item;
uniform float weapon_rank = 0.0;
uniform float armor_rank = 0.0;
void fragment() {
	// Godot already samples the texture into COLOR; keep its alpha and tint once.
	vec4 pixel = COLOR;
	float hi = max(pixel.r,max(pixel.g,pixel.b));
	float lo = min(pixel.r,min(pixel.g,pixel.b));
	float metal = (1.0-smoothstep(0.12,0.3,hi-lo))*smoothstep(0.16,0.36,hi);
	vec3 tier = mix(vec3(0.11,0.10,0.14),vec3(0.24,0.18,0.28),armor_rank/3.0);
	pixel.rgb += metal * tier * armor_rank * 0.07;
	float enchant = smoothstep(0.24,0.5,hi-lo)*smoothstep(0.35,0.85,hi);
	pixel.rgb += enchant * vec3(0.15,0.11,0.18) * weapon_rank * (0.08+0.025*sin(TIME*1.4));
	COLOR = pixel;
}
