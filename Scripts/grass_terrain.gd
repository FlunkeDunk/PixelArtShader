extends MeshInstance3D
@onready var multiMeshInstance3d: MultiMeshInstance3D = $MultiMeshInstance3D
@onready var multiMesh: MultiMesh = multiMeshInstance3d.multimesh
@onready var grassMesh: MeshInstance3D = $MultiMeshInstance3D/GrassMesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var meshDataTool := MeshDataTool.new()
	meshDataTool.create_from_surface(mesh, 0)
	
	var areaSum: float = 0.0
	var areaArray: Array[float] = []
	
	for i in range(meshDataTool.get_face_count()):
		# Get the index in the vertex array.
		var a: int = meshDataTool.get_face_vertex(i, 0)
		var b: int = meshDataTool.get_face_vertex(i, 1)
		var c: int = meshDataTool.get_face_vertex(i, 2)
		# Get vertex position using vertex index.
		var aPoint: Vector3 = meshDataTool.get_vertex(a)
		var bPoint: Vector3 = meshDataTool.get_vertex(b)
		var cPoint: Vector3 = meshDataTool.get_vertex(c)
		# Calculate face normal.
		var normal: Vector3 = (bPoint - cPoint).cross(aPoint - bPoint).normalized()
		
		var aLength: float = bPoint.distance_to(cPoint)
		var bLength: float = aPoint.distance_to(cPoint)
		var cLength: float = aPoint.distance_to(bPoint)
		
		var s: float = (aLength + bLength + cLength) * 0.5
		
		var area: float = sqrt(s * (s - aLength) * (s - bLength) * (s - cLength))
		areaArray.append(area)
		areaSum += area
	
	# Create the multimesh.
	multiMesh = MultiMesh.new()
	# Set the format first.
	multiMesh.transform_format = MultiMesh.TRANSFORM_3D
	multiMesh.use_colors = true
	multiMesh.mesh = grassMesh.mesh
	# Then resize (otherwise, changing the format is not allowed).
	multiMesh.instance_count = 500
	multiMesh.visible_instance_count = multiMesh.instance_count
	
	for i in multiMesh.visible_instance_count:
		var randomArea: float = randf_range(0, areaSum)
		var j: int = 0
		var tempAreaSum: float = 0
		for area: float in areaArray:
			tempAreaSum += area
			if tempAreaSum > randomArea:
				break
			j += 1
		
		var a: int = meshDataTool.get_face_vertex(j, 0)
		var b: int = meshDataTool.get_face_vertex(j, 1)
		var c: int = meshDataTool.get_face_vertex(j, 2)
		# Get vertex position using vertex index.
		var aPoint: Vector3 = meshDataTool.get_vertex(a)
		var bPoint: Vector3 = meshDataTool.get_vertex(b)
		var cPoint: Vector3 = meshDataTool.get_vertex(c)
		var randomPoint: Vector3 = aPoint + (bPoint - aPoint) * randf() + (cPoint - aPoint) * randf()
		var normal: Vector3 = meshDataTool.get_face_normal(j)
		var meshPosition := Transform3D()
		meshPosition = meshPosition.translated(randomPoint * scale + global_position)

		multiMesh.set_instance_transform(i, meshPosition)
		multiMesh.set_instance_color(i, Color(normal.x, normal.y, normal.z, 1.0))
