shader_type canvas_item;
// Ekran geçişi: ortadan büyüyen, kenarı dalgalı mürekkep lekesi.
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 ink : source_color = vec4(0.12, 0.23, 0.58, 1.0);
uniform float aspect = 0.5625;
void fragment() {
	vec2 d = UV - vec2(0.5, 0.55);
	d.x *= aspect;
	float a = atan(d.y, d.x);
	float r = length(d);
	float wobble = sin(a * 7.0 + progress * 9.0) * 0.025 + sin(a * 13.0 - progress * 5.0) * 0.015;
	float edge = progress * 1.05 + wobble * progress;
	COLOR = vec4(ink.rgb, ink.a * (1.0 - smoothstep(edge - 0.004, edge + 0.004, r)));
}
