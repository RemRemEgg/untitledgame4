shader_type spatial;
render_mode unshaded,cull_disabled;

varying vec3 position;

void vertex() {
	position = VERTEX;
}

const float SCALE = 12.0;

void fragment() {
	vec2 pos = vec2(floor(UV.y * 144.0 * 18.0 + TIME * 1.2), floor(UV.x * 512.0));
	float v = float(int(abs(pos.x*pos.y+floor(TIME)))%int(SCALE)) / SCALE - 0.5;
	float n = float(int(abs(pos.x*pos.y+floor(TIME)+1.0))%int(SCALE)) / SCALE - 0.5;
	float j = (TIME - floor(TIME)) * (n - v) * 0.8 + v;
	j = clamp(j*4.0, 0.0, 0.5);
	ALBEDO = vec3(0.0, j * 0.5, j) + vec3(0.0, 0.1, 0.2);
	ALPHA = (j)/(j+2.0) + 0.1;
	//ALPHA = 1.0;
}