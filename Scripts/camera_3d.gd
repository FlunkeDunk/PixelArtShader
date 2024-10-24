extends Camera3D
@onready var pointer: Node3D = get_parent()

func _process(delta: float) -> void:
	if Input.is_action_pressed("move_forward"):
		pointer.rotation.x += -1 * delta
	elif Input.is_action_pressed("move_backward"):
		pointer.rotation.x += 1 * delta
	else:
		pointer.rotation.x += 0 * delta

	if Input.is_action_pressed("move_right"):
		pointer.rotation.y += 1 * delta
	elif Input.is_action_pressed("move_left"):
		pointer.rotation.y += -1 * delta
	else:
		pointer.rotation.y += 0 * delta
Material
