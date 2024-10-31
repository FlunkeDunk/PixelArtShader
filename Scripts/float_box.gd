@tool
extends MeshInstance3D

var time: float = 0


func _process(delta: float) -> void:
	time += delta
	rotate_y(delta)
	position.y = 3.0 + sin(time)
