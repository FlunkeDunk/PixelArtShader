extends Camera3D

@export var snapping: bool = true

@onready var texelSize: float = size / 182
@onready var snapSpace: Transform3D = global_transform
var snappedDistanceInScreenSpace: Vector2 = Vector2.ZERO
@onready var prevRotation: Vector3 = global_rotation



func _process(delta: float) -> void:
	
	if snapping:
		snap()

func snap() -> void:
	if prevRotation != global_rotation:
		snapSpace = global_transform
		prevRotation = global_rotation
	var snapSpacePosition: Vector3 = global_position * snapSpace
	
	var snappedSnapSpacePosition: Vector3 = snapSpacePosition.snapped(Vector3.ONE * texelSize)
	
	var snappedDifference: Vector3 = snappedSnapSpacePosition - snapSpacePosition
	
	snappedDistanceInScreenSpace = Vector2(snappedDifference.x, -snappedDifference.y) / texelSize
	
	h_offset = snappedDifference.x
	v_offset = snappedDifference.y
