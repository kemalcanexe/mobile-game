shader_type spatial;
// Stilize çimen: büyük ölçekli iki tonlu lekeler + küçük kırıntı; biçilmiş şerit izi.
uniform vec3 grass_a : source_color = vec3(0.36, 0.66, 0.30);
uniform vec3 grass_b : source_color = vec3(0.50, 0.76, 0.34);
uniform float stripe = 3.0;
varying vec3 wpos;
float h(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float n(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h(i), h(i + vec2(1, 0)), f.x), mix(h(i + vec2(0, 1)), h(i + vec2(1, 1)), f.x), f.y);
}
void vertex() { wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	float big = n(wpos.xz * 0.12) * 0.6 + n(wpos.xz * 0.5) * 0.4;
	float mow = step(0.5, fract(wpos.x / stripe)) * 0.06;
	vec3 c = mix(grass_a, grass_b, big) * (0.94 + mow + h(floor(wpos.xz * 6.0)) * 0.05);
	ALBEDO = c;
	ROUGHNESS = 0.95;
}
