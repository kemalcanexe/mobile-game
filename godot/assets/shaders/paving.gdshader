shader_type spatial;
// Kampüs kaldırımı: yarım kaydırmalı dikdörtgen taşlar, ton farkı ve kenar gölgesi.
uniform vec3 stone_a : source_color = vec3(0.82, 0.76, 0.66);
uniform vec3 stone_b : source_color = vec3(0.70, 0.64, 0.55);
uniform vec3 joint : source_color = vec3(0.45, 0.42, 0.38);
uniform vec2 stone = vec2(0.9, 0.6);
varying vec3 wpos;
float h(vec2 p) { return fract(sin(dot(p, vec2(41.3, 289.1))) * 43758.5453); }
void vertex() { wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	vec2 g = wpos.xz / stone;
	g.x += mod(floor(g.y), 2.0) * 0.5;
	vec2 cell = floor(g);
	vec2 f = fract(g);
	float id = h(cell);
	vec3 c = mix(stone_a, stone_b, id * id);
	float e = min(min(f.x, 1.0 - f.x) * stone.x, min(f.y, 1.0 - f.y) * stone.y);
	float edge = smoothstep(0.015, 0.05, e);
	ALBEDO = mix(joint, c * (0.92 + 0.08 * smoothstep(0.05, 0.2, e)), edge);
	ROUGHNESS = 0.85;
}
