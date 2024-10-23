extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(updateScreenSize)
	updateScreenSize()

func updateScreenSize() -> void:
	material.set_shader_parameter("screenSize", DisplayServer.window_get_size())
	print(DisplayServer.window_get_size())
