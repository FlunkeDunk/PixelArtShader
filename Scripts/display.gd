extends SubViewportContainer

@export var smooth: bool = true

@onready var pixelArtCamera: Camera3D = $SubViewport/World/CameraRigger/PixelArtCamera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var prev
func _process(delta: float) -> void:
	if smooth:
		position = Vector2(-6, -6) + pixelArtCamera.snappedDistanceInScreenSpace * 6
	else:
		position = Vector2(-6, -6)
