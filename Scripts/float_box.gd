@tool
extends MeshInstance3D

var time: float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	rotate_y(delta)
	position.y = 2.2 + sin(time)
