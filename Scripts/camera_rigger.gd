extends Marker3D


@export_range(0.1, 2, 0.01) var movementSpeed: float

var initialRotationY: float = rotation.y
var velocity: Vector3 = Vector3.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var motion: Vector3 = Vector3.ZERO
	
	if Input.is_action_pressed("move_left"):
		motion.x += -1
		motion.z += 1
	elif Input.is_action_pressed("move_right"):
		motion.x += 1
		motion.z += -1
	else:
		motion.x = 0
		
	if Input.is_action_pressed("move_forward"):
		motion.x += -1
		motion.z += -1
	elif Input.is_action_pressed("move_backward"):
		motion.z += 1
		motion.x += 1
	else:
		motion.z += 0
	
	#motion = motion.normalized()

	
	velocity += motion * movementSpeed * 0.001
	velocity *= 0.9
	position += velocity
