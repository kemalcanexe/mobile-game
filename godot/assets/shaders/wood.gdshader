shader_type spatial;
// Dünya uzayında tahta döşeme / parke: z boyunca tahtalar, sıra başına kaydırılmış derz ve ton farkı.
uniform vec3 base_a : source_color = vec3(0.62, 0.38, 0.22);
uniform vec3 base_b : source_color = vec3(0.50, 0.29, 0.16);
uniform float plank_w = 0.42;
uniform float plank_l = 2.4;
uniform float seam_dark = 0.45;
uniform float gloss = 0.45;
varying vec3 wpos;
float h(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
void vertex() { wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	float col = floor(wpos.x / plank_w);
	float off = h(vec2(col, 3.1)) * plank_l;
	float row = floor((wpos.z + off) / plank_l);
	float id = h(vec2(col, row));
	vec2 f = vec2(fract(wpos.x / plank_w), fract((wpos.z + off) / plank_l));
	float seam = smoothstep(0.0, 0.035, f.x) * smoothstep(1.0, 0.965, f.x) * smoothstep(0.0, 0.012, f.y) * smoothstep(1.0, 0.988, f.y);
	float grain = sin((wpos.z + id * 7.0) * 9.0 + sin(wpos.x * 3.0 + id * 5.0) * 2.0) * 0.5 + 0.5;
	vec3 c = mix(base_a, base_b, id) * (0.92 + grain * 0.12);
	ALBEDO = c * mix(seam_dark, 1.0, seam);
	ROUGHNESS = gloss;
	SPECULAR = 0.35;
}
