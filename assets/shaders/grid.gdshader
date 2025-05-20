shader_type spatial;
render_mode world_vertex_coords;

uniform vec3 MOD = vec3(1.0, 1.0, 1.0);
varying vec3 posi;

void vertex() {
	posi = VERTEX / 2.0;
}

void fragment() {
	ALBEDO = vec3(max(abs(posi.x-round(posi.x))-.45, 0) + max(abs(posi.y-round(posi.y))-.45, 0) + max(abs(posi.z-round(posi.z))-.45, 0))*50.0 + fwidth(posi);
	ALBEDO *= MOD;
}