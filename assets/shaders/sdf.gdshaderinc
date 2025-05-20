float sdf_box( vec3 point, vec3 size ) {
	point = abs(point) - size;
	return length(max(point, 0.0)) + min(max(point.x, max(point.y, point.z)), 0.0);
}

float sdf_cylinder_inf( vec3 point, float r ) {
	return length(point.xz) - r;
}

float sdf_cylinder_capped( vec3 point, float h, float r ) {
	vec2 d = abs(vec2(length(point.xz),point.y)) - vec2(r,h);
	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdf_capsule_vert( vec3 point, float h, float r ) {
	point.y -= clamp(point.y, 0.0, h);
	return length(point) - r;
}

float sdf_sphere( vec3 point, float radius ) {
	return length(point) - radius;
}

float sdf_torus( vec3 point, vec2 size ) {
	vec2 q = vec2(length(point.xz) - size.x, point.y);
	return length(q) - size.y;
}

float smooth_union( float sdf1, float sdf2, float k ) {
	float h = clamp( 0.5 + 0.5*(sdf2-sdf1)/k, 0.0, 1.0 );
	return mix( sdf2, sdf1, h ) - k*h*(1.0-h);
}
