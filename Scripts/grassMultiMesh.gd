extends MultiMeshInstance3D
@export var terrain: MeshInstance3D

@export var grassMesh: MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var meshDataTool := MeshDataTool.new()
	meshDataTool.create_from_surface(terrain.mesh, 0)
	
	var areaSum: float = 0.0
	var areaArray: Array[float] = []
	
	for i in range(meshDataTool.get_face_count()):
		# Get vertices of the triangle
		var a: int = meshDataTool.get_face_vertex(i, 0)
		var b: int = meshDataTool.get_face_vertex(i, 1)
		var c: int = meshDataTool.get_face_vertex(i, 2)
		
		var aPoint: Vector3 = meshDataTool.get_vertex(a)
		var bPoint: Vector3 = meshDataTool.get_vertex(b)
		var cPoint: Vector3 = meshDataTool.get_vertex(c)
		
		# Calculate triangle area
		var area: float = (bPoint - aPoint).cross(cPoint - aPoint).length() / 2
		areaArray.append(area)
		areaSum += area
	
	# Initialize MultiMesh
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.set_use_colors(true)
	multimesh.mesh = grassMesh.mesh
	multimesh.instance_count = 2000
	
	for i in range(multimesh.instance_count):
		var randomArea: float = randf_range(0, areaSum)
		var j: int = 0
		var tempAreaSum: float = 0
		
		for area in areaArray:
			tempAreaSum += area
			if tempAreaSum > randomArea:
				break
			j += 1
		
		# Retrieve vertices of selected triangle
		var a: int = meshDataTool.get_face_vertex(j, 0)
		var b: int = meshDataTool.get_face_vertex(j, 1)
		var c: int = meshDataTool.get_face_vertex(j, 2)
		var aPoint: Vector3 = meshDataTool.get_vertex(a)
		var bPoint: Vector3 = meshDataTool.get_vertex(b)
		var cPoint: Vector3 = meshDataTool.get_vertex(c)
		
		# Use barycentric coordinates for uniform random point within triangle
		var u: float = randf()
		var v: float = randf()
		if u + v > 1.0:
			u = 1.0 - u
			v = 1.0 - v
		var randomPoint: Vector3 = aPoint + (bPoint - aPoint) * u + (cPoint - aPoint) * v
		
		# Apply terrain scale and position
		randomPoint = randomPoint
		
		# Get normal and set transformation
		var normal: Vector3 = meshDataTool.get_face_normal(j).normalized()
		var meshPosition := Transform3D(Basis(), randomPoint)
		multimesh.set_instance_transform(i, meshPosition)
		multimesh.set_instance_color(i, Color(normal.x, normal.y, normal.z, 1.0))
