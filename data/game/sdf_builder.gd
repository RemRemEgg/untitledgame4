class_name SDFBuilder
extends Node3D

var sdfs: PackedStringArray = PackedStringArray()
var colors: PackedStringArray = PackedStringArray()
var groups: int = 0

#################
func _ready() -> void:
	(get_child(0) as MeshInstance3D).material_override = build_shader_3D(Vector3(0.1, 0.5, 0.5))
func _process(delta: float) -> void:
	(get_child(0) as MeshInstance3D).rotate(Vector3.UP, delta)
func three_rng(m:float, M:float) -> String:
	return str(randf_range(m,M)) + "," + str(randf_range(m,M)) + "," + str(randf_range(m,M))
#################

func build_shader_3D(color: Vector3) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	var shader := Shader.new()
	build_shader_code_3D(shader, color)
	mat.shader = shader
	return mat


func build_shader_code_3D(shader: Shader, color: Vector3) -> void:
	add_group_3D("""
	float b = sdf_cylinder_capped(point.yxz - vec3(0.0, 0.15, 0.0), 1.55, 0.3);
	float c = sdf_box(point - vec3(-0.95, 0.0, 0.0), vec3(0.55, 0.35, abs(point.x*0.3) * abs(point.y*0.25+0.5)));
	return max(b,-min(c, length(point) - 0.335));
	""","""
	ALBEDO = vec3(""" +str(color.x)+","+str(color.y)+","+str(color.z)+ """) * 0.8;
	""")
	
	
	add_group_3D("""
	point.z = abs(point.z);
	point -= vec3(-0.25, 0.0, 0.8);
	float e = max(dot(vec2(0.2588190451, 0.96592582628).yx, vec2(length(point.yz),point.x)),-1.0-point.x);
	
	float b =
	max(max(dot(point, normalize(vec3(0, 1, 0) * vec3(""" + three_rng(0.5, 1.5) + """))) - """ + str(0.1 + randf_range(0, 0.25)) + """,
	dot(point, normalize(vec3(0, -1, -1) * vec3(""" + three_rng(0.5, 1.5) + """))) - """ + str(0.1 + randf_range(0, 0.25)) + """),
	
	max(max(dot(point, normalize(vec3(0.2, 1, 1) * vec3(""" + three_rng(0.5, 1.5) + """))) - """ + str(0.2 + randf_range(0, 0.25)) + """,
	dot(point, normalize(vec3(1, 1, 1) * vec3(""" + three_rng(0.5, 1.5) + """))) - """ + str(0.6 + randf_range(0, 0.45)) + """),
	
	max(dot(point, normalize(vec3(0, -1, 0) * vec3(""" + three_rng(0.5, 1.5) + """))) - """ + str(0.1 + randf_range(0, 0.25)) + """,
	dot(point, normalize(-vec3(0.8, 0.2, 0.1) * vec3(""" + three_rng(0.5, 1.5) + """))) - """ + str(0.2 + randf_range(0, 0.25)) + """)));
	
	return min(e, b);
	""", """
	ALBEDO = vec3(""" +str(color.x)+","+str(color.y)+","+str(color.z)+ """) * 0.4 * normalize(vec3(""" + three_rng(0.5, 1.5) + """));
	""")
	
	add_group_3D("""
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
	""", """
	ray_pos = normalize(ray_pos);
	int a = int(ray_pos.x*100.0);
	int b = int(ray_pos.y*100.0);
	int c = int(ray_pos.z*100.0);
	ALBEDO = clamp(vec3(0.3, 0.7, 1.0) * 0100.01 * abs(float(a^b + b^c + c^a)), 0.0, 1.5);
	""")
	
	shader.code = SDF_MAT_SDFS_3D + "\n\n".join(sdfs) + generate_min_all_3D(groups) + SDF_MAT_COLORS_3D + "\n".join(colors) + SDF_FOOTER_3D


func add_group_3D(sdf: String, color: String) -> void:
	sdfs.append("float mat_group_" + str(groups) + "(vec3 point) {" + sdf.strip_edges() + "}")
	colors.append(generate_color_3D(groups, color.strip_edges()))
	groups += 1

static func generate_min_all_3D(n: int) -> String:
	if n <= 0: return "100.0"
	return "\n\nfloat sdf_all( vec3 point ) { return " + recur_min_all(n, nearest_po2(n), 1) + ";}\n"

static func recur_min_all(max: int, c: int, o: int) -> String:
	if c == 1: return "mat_group_" + str(o-1) + "(point)"
	else:
		c /= 2
		if o + c <= max: return "min(" + recur_min_all(max, c, o) + "," + recur_min_all(max, c, o + c) + ")"
		else: return recur_min_all(max, c, o)

static func generate_color_3D(i: int, color: String) -> String:
	return """
	tst = mat_group_""" + str(i) + """(ray_pos); d = min(d, tst); if (tst <= FI) {
	""" + color + """
	break; }"""

static func generate_color_2D(i: int, color: String) -> String:
	return """
	d = mat_group_""" + str(i) + """(ray_pos); d = min(d, tst); if (tst <= FI) {
	""" + color + """
	break; }"""

const SDF_MAT_SDFS_3D := """shader_type spatial;
render_mode unshaded;
#include "res://assets/shaders/raycast.gdshaderinc"
#include "res://assets/shaders/sdf.gdshaderinc"
const vec3 LIGHT_DIR = -vec3(-0.5, -1.5, 0.9);
const float FI = 0.005;
instance uniform bool hurt = false;

"""

const SDF_MAT_COLORS_3D := """
//const float h = 0.005;
vec3 get_sdf_normal( vec3 point, float h ) {
	return normalize(
		vec3(1,-1,-1)*sdf_all(point + vec3(1,-1,-1)*h) +
		vec3(1,1,1)*sdf_all(point + vec3(1,1,1)*h) +
		vec3(-1,-1,1)*sdf_all(point + vec3(-1,-1,1)*h) +
		vec3(-1,1,-1)*sdf_all(point + vec3(-1,1,-1)*h)
	);
}

void fragment() {
	vec3 ray_dir, ray_org;
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
		"""

const SDF_FOOTER_3D := """
	
	t += d;
	}; if (t > 8.0) discard;
	
	ray_pos = ray_org + ray_dir*t;
	vec3 normal = get_sdf_normal(ray_pos, 0.001);
	vec3 light_dir = normalize((vec4(LIGHT_DIR, 1.0) * MODEL_MATRIX).xyz);
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
}"""
