vec2 ray_box_intersect( vec3 point, vec3 dir, vec3 bounds ) {
	float tmin, tmax;
	vec3 t1 = (-bounds - point) / dir;
	vec3 t2 = (bounds - point) / dir;
	tmin = max(max(min(t1.x, t2.x), min(t1.y, t2.y)), min(t1.z, t2.z));
	tmax = min(min(max(t1.x, t2.x), max(t1.y, t2.y)), max(t1.z, t2.z));
	return vec2(tmin, tmax);
}

bool snap_bounds( inout vec3 point, vec3 dir, vec3 bounds ) {
	float b = length(max(abs(point) - bounds, 0.0));
	if (b > 0.0) {
		vec2 rbi = ray_box_intersect(point, dir, bounds);
		point += rbi.x * dir;
		return 0.0 <= rbi.x && rbi.x <= rbi.y;// && sdf_box(point + dir * 0.01, bounds) <= b;
	}
	return true;
}

void setup(inout vec3 ray_dir, inout vec3 ray_org, vec3 pVIEW, vec3 pVERTEX, mat4 pVIEW_MATRIX, mat4 pMODEL_MATRIX) {
	ray_dir = -pVIEW;
	ray_org = pVERTEX - ray_dir  * pVERTEX.z/ray_dir.z;
	mat4 inv_modelview = inverse(pVIEW_MATRIX * pMODEL_MATRIX);
	ray_org = (inv_modelview * vec4(ray_org, 1.0)).xyz;
	ray_dir = normalize( mat3(inv_modelview) * ray_dir );
}