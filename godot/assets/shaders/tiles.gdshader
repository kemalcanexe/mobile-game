shader_type spatial;
// Kare fayans: iki renkli dama (checker) ya da tek renk + derz; hafif parlak.
uniform vec3 color_a : source_color = vec3(0.95, 0.95, 0.93);
uniform vec3 color_b : source_color = vec3(0.12, 0.13, 0.16);
uniform float tile = 1.0;
uniform float checker = 1.0;
uniform vec3 grout : source_color = vec3(0.6, 0.6, 0.62);
uniform float grout_w = 0.03;
uniform float gloss = 0.25;
varying vec3 wpos;
float h(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void vertex() { wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	vec2 g = wpos.xz / tile;
	vec2 cell = floor(g);
	vec2 f = fract(g);
	float par = mod(cell.x + cell.y, 2.0);
	vec3 c = mix(color_a, mix(color_a, color_b, par), checker);
	c *= 0.96 + h(cell) * 0.06;
	float gl = step(grout_w, f.x) * step(grout_w, f.y);
	ALBEDO = mix(grout, c, gl);
	ROUGHNESS = gloss;
	SPECULAR = 0.5;
}
