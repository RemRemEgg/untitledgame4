shader_type spatial;
render_mode unshaded;
#include "res://assets/shaders/raycast.gdshaderinc"
#include "res://assets/shaders/sdf.gdshaderinc"
const vec3 LIGHT_DIR = vec3(0.657041, 0.657041, 0.369586);
const float FI = 0.005;
instance uniform bool hurt = false;

float mat_group_0(vec3 point) {float b = sdf_cylinder_capped(point.yxz - vec3(0.0, 0.15, 0.0), 1.55, 0.3);
	float c = sdf_box(point - vec3(-0.95, 0.0, 0.0), vec3(0.55, 0.35, abs(point.x*0.3) * abs(point.y*0.25+0.5)));
	return max(b,-min(c, length(point) - 0.335));}

float mat_group_1(vec3 point) {point.z = abs(point.z);
	point -= vec3(-0.25, 0.0, 0.8);
	float e = max(dot(vec2(0.2588190451, 0.96592582628).yx, vec2(length(point.yz),point.x)),-1.0-point.x);
	
	float b =
	max(max(dot(point, vec3(0, 1, 0)) - 0.25,
	dot(point, vec3(0, -1, -1)) - 0.25),
	
	max(max(dot(point, normalize(vec3(0.2, 1, 1))) - 0.3,
	dot(point, normalize(vec3(1, 1, 1))) - 0.8),
	
	max(dot(point, vec3(0, -1, 0)) - 0.25,
	dot(point, normalize(-vec3(0.8, 0.2, 0.1))) - 0.3)));
	
	return min(e, b);}

float mat_group_2(vec3 point) {
	float lp = length(point);
	float sphere = length(lp) - 0.27;
	float time = TIME*1.0 + 1.0;
	vec3 plane_dir = normalize(vec3(cos(time*2.0), cos(time*0.4), sin(time*2.0)));
	float plane1 = dot(point, plane_dir);
	float plane2 = dot(point.yxz, plane_dir);
	float plane3 = dot(point.xzy, plane_dir);
	float disk1 = max(max(abs(sphere) - 0.001, plane1), -plane1);
	float disk2 = max(max(abs(sphere) - 0.001, plane2), -plane2);
	float disk3 = max(max(abs(sphere) - 0.001, plane3), -plane3);
	
	return min(min(min(disk1, disk2), disk3) - 0.02, length(lp) - 0.2);
}

float sdf_all( vec3 point ) { return min(min(mat_group_0(point),mat_group_1(point)),mat_group_2(point));}

//const float h = 0.01;
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
	if (!snap_bounds(ray_org, ray_dir, vec3(3.0))) discard;
	ALBEDO = vec3(0.0);
	
	float d = 0.0, t = 0.01;
	vec3 ray_pos;
	float tst = 0.0;
	int i = 0;
	for (; i < 4; i++) {
		ray_pos = ray_org + ray_dir*t;
		d = sdf_all(ray_pos);
		t += max(0.0, d);
		if (d < FI) break;
	}
	for (; i < 100 && t < 8.0; i++) {
		ray_pos = ray_org + ray_dir*t;
		d = 500.0;
		
	tst = mat_group_0(ray_pos); d = min(d, tst); if (tst <= FI) {
	ALBEDO = vec3(0.95, 0.9, 0.85) * 0.8;
	break; }

	tst = mat_group_1(ray_pos); d = min(d, tst); if (tst <= FI) {
	ALBEDO = vec3(0.5, 0.5, 0.6) * 0.4;
	break; }

	tst = mat_group_2(ray_pos); d = min(d, tst); if (tst <= FI) {
	ray_pos = normalize(ray_pos);
	int a = int(ray_pos.x*100.0);
	int b = int(ray_pos.y*100.0);
	int c = int(ray_pos.z*100.0);
	ALBEDO = vec3(0.3, 0.7, 1.0) * 0.015 * abs(float(a^b + b^c + c^a));
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
	
	vec3 fw_normal = get_sdf_normal(ray_pos, 0.01);
	float fw = length(fwidth(fw_normal));
	light_level *= 1.0 + fw*1.5;
	
	ALBEDO *= clamp(light_level, 0.01, 1.05);
	ALBEDO = 0.6 * (ALBEDO * ALBEDO + ALBEDO * 2.0);
	if (hurt) ALBEDO = (vec3(1.0)*0.3 + ALBEDO) / 1.3;
}