shader_type spatial;

const vec3 D_GREEN = vec3(0.05, 0.6, 0.1);
const vec3 M_GREEN = vec3(0.17, 0.86, 0.25);
const vec3 GREEN = vec3(0.3, 0.95, 0.4);
const vec3 G_BROWN = vec3(0.32, 0.7, 0.3);
const vec3 BROWN = vec3(0.4, 0.25, 0.1);
const vec3 GRAY = vec3(0.3, 0.3, 0.36);
const vec3 COLORS[] = {GRAY, BROWN, (GREEN * 4.0 + BROWN)/5.0, GREEN, M_GREEN, D_GREEN};

uniform float OFFSET = -0.1;
uniform float SCALE = 10.1;
uniform float HALF_POINT = 3.0;

varying vec3 V_COLOR;
varying float t;

void vertex() {
	V_COLOR = NORMAL;
	t = NORMAL.y * NORMAL.y;
	t = clamp(SCALE * (t / (t+HALF_POINT)) + OFFSET, 0, 1) * 5.0;
	V_COLOR = COLORS[int(t)];
}

void fragment() {
	float ti = t - floor(t);
	ti = 3.0*(ti*ti) - 2.0*(ti*ti*ti);
	int i = int(t);
	ALBEDO = ti * (COLORS[i+1] - COLORS[i]) + COLORS[i] * 0.5;
}