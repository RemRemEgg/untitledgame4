class_name TerrainGenerator
extends Resource

var size: Vector2i
var mesh: ArrayMesh
var surface_array: Array
var verts: PackedVector3Array
var uvs: PackedVector2Array
var normals: PackedVector3Array
var indices: PackedInt32Array

func index(x:int, y:int) -> int: return x + y*size.x

func plane(_size: Vector2i) -> TerrainGenerator:
	size = _size
	surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	verts = PackedVector3Array()
	uvs = PackedVector2Array()
	normals = PackedVector3Array()
	indices = PackedInt32Array()
	
	for y in range(size.y):
		for x in range(size.x):
			var index := x + (y*size.x)
			var vert := Vector3(x-size.x/2.0, 0, y-size.y/2.0)
			verts.append(vert)
			normals.append(vert.normalized())
			uvs.append(Vector2(0, 0))
			if x != 0 && y != 0:
				indices.append(index)
				indices.append(index-1)
				indices.append(index-size.x)
				indices.append(index-1)
				indices.append(index-size.x-1)
				indices.append(index-size.x)
	return self

func build_surface_array() -> TerrainGenerator:
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	return self

func build_mesh() -> TerrainGenerator:
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	return self

func update_normals() -> TerrainGenerator:
	var mdt: MeshDataTool = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_face_count()):
		var a := mdt.get_face_vertex(i, 0)
		var b := mdt.get_face_vertex(i, 1)
		var c := mdt.get_face_vertex(i, 2)
		var ap := mdt.get_vertex(a)
		var bp := mdt.get_vertex(b)
		var cp := mdt.get_vertex(c)
		var n := (bp - cp).cross(ap - bp).normalized()
		mdt.set_vertex_normal(a, n + mdt.get_vertex_normal(a))
		mdt.set_vertex_normal(b, n + mdt.get_vertex_normal(b))
		mdt.set_vertex_normal(c, n + mdt.get_vertex_normal(c))
	for i in range(mdt.get_vertex_count()):
		var v := mdt.get_vertex_normal(i).normalized()
		mdt.set_vertex_normal(i, v)
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	return self
