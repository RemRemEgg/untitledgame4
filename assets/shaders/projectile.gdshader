shader_type spatial;

float mat_group_0(vec2 point) {
	point.x *= 0.5;
	return abs(point.y) + abs(point.x+0.1 - abs(point.y)*0.5) - 0.333;
}

float mat_group_1(vec2 point) {
	point.x *= 0.5;
	return abs(point.y) + abs(point.x+0.22 - abs(point.y)*0.5) - 0.5;
}

void render(out vec3 albedo, out float alpha, vec2 point) {
	float d = 0.0;
	
	d = mat_group_0(point); if (d < 0.0) {
		d = floor(-d * 3.0 * 4.0) / 4.0;
		albedo = vec3(1.0, 0.0, -0.5) + vec3(0.0, 1.0, 1.0) * d;
		alpha = 1.0;
	return;}
	
	d = mat_group_1(point); if (d < 0.0) {
		albedo = vec3(1.0, 0.0, 0.0) + vec3(-0.0, 1.0, 0.0) * -d;
		d *= -5.;
		alpha = d / (d + 8.0);
	return;}
	
	discard;
}

void fragment() {
	vec2 pos = UV * vec2(4.0, 2.0) - vec2(2.5, 1.0);
	render(ALBEDO, ALPHA, pos);
	EMISSION = ALBEDO;
}