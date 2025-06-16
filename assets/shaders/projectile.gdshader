/*shader_type spatial;
render_mode unshaded;
#include "res://assets/shaders/raycast.gdshaderinc"
#include "res://assets/shaders/sdf.gdshaderinc"
const vec3 LIGHT_DIR = -normalize(vec3(-0.5, -1.5, 0.9));
const float FI = 0.005;

float mat_group_0(vec3 point) {
	//float b = sdf_cylinder_capped(point.yxz - vec3(0.0, 0.15, 0.0), 1.55, 0.3);
	//float c = sdf_box(point - vec3(-0.95, 0.0, 0.0), vec3(0.55, 0.35, abs(point.x*0.3) * abs(point.y*0.25+0.5)));
	//return max(b,-min(c, length(point) - 0.335));
	//point.y *= 0.9;
	//return abs(point.x) + abs(point.y + abs(point.x)*0.25) - 0.15;
	//point.y *= 0.9;
	//return abs(point.x) + abs(point.y) + abs(point.z) - 0.6;// + abs(point.y + abs(point.x)*0.25) - 0.15;
	//return length(point) - 0.3;
	vec3 r = vec3(0.35, 0.15, 0.22);
	float k0 = length(point/r);
	float k1 = length(point/(r*r));
	return k0*(k0-1.0)/k1;
}

float mat_group_1(vec3 point) {
	//float b = sdf_cylinder_capped(point.yxz - vec3(0.0, 0.15, 0.0), 1.55, 0.3);
	//float c = sdf_box(point - vec3(-0.95, 0.0, 0.0), vec3(0.55, 0.35, abs(point.x*0.3) * abs(point.y*0.25+0.5)));
	//return max(b,-min(c, length(point) - 0.335));
	//point.y *= 0.9;
	//return abs(point.x) + abs(point.y + abs(point.x)*0.25) - 0.15;
	//point.y *= 0.9;
	//return abs(point.x) + abs(point.y) + abs(point.z) - 0.6;// + abs(point.y + abs(point.x)*0.25) - 0.15;
	//return length(point) - 0.3;
	vec3 r = vec3(0.35, 0.15, 0.22) * 1.1;
	float k0 = length(point/r);
	float k1 = length(point/(r*r));
	return k0*(k0-1.0)/k1;
}

float sdf_all( vec3 point ) { return mat_group_0(point);}

vec3 get_sdf_normal( vec3 point, float h ) {
	return normalize(
		vec3(1,-1,-1)*sdf_all(point + vec3(1,-1,-1)*h) +
		vec3(1,1,1)*sdf_all(point + vec3(1,1,1)*h) +
		vec3(-1,-1,1)*sdf_all(point + vec3(-1,-1,1)*h) +
		vec3(-1,1,-1)*sdf_all(point + vec3(-1,1,-1)*h)
	);
}

void fragment() {
	vec3 ray_dir, ray_org, trash;
	setup(ray_dir, ray_org, VIEW, VERTEX, VIEW_MATRIX, MODEL_MATRIX);
	if (!snap_bounds(ray_org, ray_dir, vec3(2.0))) discard;
	//ray_dir = vec3(0.0, -1.0, 0.0);
	//ray_dir.y *= 1.0;
	//ray_dir.y = 0.0;
	//ray_dir = normalize(ray_dir);
	ALBEDO = vec3(0.0);
	
	float d = 0.0, t = 0.01;
	vec3 ray_pos;
	float tst = 0.0;
	for (int i = 0; i < 30 && t < 8.0; i++) {
		ray_pos = ray_org + ray_dir*t;
		d = 500.0;
		
	tst = mat_group_0(ray_pos); d = min(d, tst); if (tst <= FI) {
	ALBEDO = vec3(0.95, 0.9, 0.85) * 0.8;
	float a = ray_pos.x*ray_pos.x + ray_pos.y*ray_pos.y + ray_pos.z*ray_pos.z;
	
	break; }
	
	t += d;
	}; if (t > 8.0) discard;
	
	ray_pos = ray_org + ray_dir*t;
	vec3 normal = get_sdf_normal(ray_pos, 0.001);
	vec3 light_dir = (vec4(LIGHT_DIR, 1.0)*MODEL_MATRIX).xyz;
	float light_level = 0.75;
	
	light_level *= max(dot(normal, light_dir), 0.0);
	
	float cx = floor(light_level * 4.0) / 4.0;
	float ll_sv = light_level-cx; ll_sv *= ll_sv; ll_sv *= ll_sv; ll_sv *= ll_sv;
	light_level = (4.*4.*4.*4.*4.*4.*4.)*ll_sv+cx;
	
	ALBEDO *= clamp(light_level, 0.01, 1.05);
	ALBEDO = 0.6 * (ALBEDO * ALBEDO + ALBEDO * 2.0);
}*/
/**/
shader_type spatial;
//render_mode unshaded;

float mat_group_0(vec2 point) {
	point.x *= 0.5;
	return abs(point.y) + abs(point.x+0.1 - abs(point.y)*0.5) - 0.32;
}

float mat_group_1(vec2 point) {
	point.x *= 0.5;
	point.x -= 0.02;
	return abs(point.y) + abs(point.x+0.24 - abs(point.y)*0.5) - 0.5;
}


void render(out vec3 albedo, out float alpha, vec2 point) {
	float d = 0.0;
	
	d = mat_group_0(point); if (d < 0.0) {
		d = floor(mat_group_0(point - vec2(0.16, 0.0)) * 4.0 * 2.0) / 4.0;
		albedo = vec3(1.0, 0.0, 0.0) + vec3(0.0, 1.0, 0.3) * -d;
		alpha = 0.9;
	return;}
	
	d = mat_group_1(point); if (d < 0.0) {
		albedo = vec3(1.0, 0.0, 0.0) + vec3(-0.0, 1.0, 0.0) * -d;
		albedo *= 1.2;
		d *= -5.;
		alpha = d / (d + 4.0);
	return;}
	
	albedo = vec3(0.0, 0.0, 0.0);
	alpha = 0.0;
}



void fragment() {
	vec2 pos = UV * vec2(4.0, 2.0) - vec2(2.5, 1.0);
	render(ALBEDO, ALPHA, pos);
	EMISSION = ALBEDO;
}