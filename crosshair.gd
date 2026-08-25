extends Control # Or TextureRect / ColorRect depending on your node type

func _ready() -> void:
	# Hides the default hardware mouse cursor during gameplay
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 

func _process(_delta: float) -> void:
	# Forces the crosshair's position to perfectly match the mouse pointer
	global_position = get_global_mouse_position()
