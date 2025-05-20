shader_type spatial;
render_mode unshaded,cull_disabled,blend_add;

varying vec3 barys;

void vertex() {
	int index = VERTEX_ID % 3;
	switch (index) {
		case 0:
			barys = vec3(1.0, 0.0, 0.0);
			break;
		case 1:
			barys = vec3(0.0, 1.0, 0.0);
			break;
		case 2:
			barys = vec3(0.0, 0.0, 1.0);
			break;
	}
}

void fragment() {
	float svc = min(barys.x, min(barys.y, barys.z));
	svc = svc < fwidth(svc) ? 0.3 : 0.15;
	ALBEDO = vec3(0.5, 0.8, 0.8);
	ALPHA = svc;
}