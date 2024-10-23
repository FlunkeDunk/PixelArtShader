extends Node3D


# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	$AnimationPlayer.play("Running_Strafe_Right")
