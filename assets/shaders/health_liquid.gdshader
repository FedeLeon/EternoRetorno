shader_type canvas_item;
// Procedural glass tube: no textures, no gameplay state or damage calculation.
uniform float level : hint_range(0.0, 1.0) = 1.0;
uniform vec2 tube_size = vec2(172.0, 25.0);
uniform float phase = 0.0;

void fragment() {
 vec2 p = UV * tube_size;
 float radius = min(7.0, tube_size.y * 0.28);
 vec2 q = abs(p - tube_size * 0.5) - (tube_size * 0.5 - vec2(radius));
 float edge = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
 float mask = 1.0 - smoothstep(-0.8, 0.0, edge);
 float rim = 1.0 - smoothstep(1.5, 2.8, -edge);
 float t = TIME + phase;
 float front = 4.0 + (tube_size.x - 8.0) * level;
 float wave = sin(p.y * 0.46 + t * 1.6) * 0.65;
 float filled = (1.0 - smoothstep(front - 0.7 + wave, front + 0.7 + wave, p.x)) * step(0.001, level);
 if (level >= 0.999) filled = 1.0;
 vec3 empty = vec3(0.065, 0.035, 0.053);
 float body = sin(UV.y * 3.14159);
 vec3 blood = mix(vec3(0.23, 0.014, 0.03), vec3(0.68, 0.05, 0.08), body);
 blood += vec3(0.04, 0.006, 0.008) * sin(p.x * 0.055 - t * 1.2 + sin(UV.y * 6.0));
 for (int i = 0; i < 7; i++) {
  float seed = float(i);
  float rise = fract(t * (0.065 + seed * 0.006) + seed * 0.173);
  vec2 center = vec2((0.08 + seed * 0.139) * tube_size.x + sin(t * 0.7 + seed) * 1.3, tube_size.y - 3.0 - rise * (tube_size.y - 6.0));
  float d = length(p - center);
  float bubble = (1.0 - smoothstep(0.4, 1.0, abs(d - (0.9 + mod(seed, 3.0) * 0.35)))) * sin(rise * 3.14159);
  blood += vec3(0.16, 0.06, 0.06) * bubble;
 }
 vec3 color = mix(empty, blood, filled);
 // Narrow glass reflection leaves the central number clear.
 float shine = exp(-pow((p.y - 4.0) / 1.0, 2.0));
 color += vec3(0.17, 0.15, 0.18) * shine;
 vec3 metal = mix(vec3(0.16, 0.14, 0.19), vec3(0.55, 0.52, 0.59), 1.0 - UV.y);
 color = mix(color, metal, rim);
 float cap = max(1.0 - step(4.0, p.x), step(tube_size.x - 4.0, p.x));
 color = mix(color, metal * 0.8, cap);
 COLOR = vec4(color, mask);
}
