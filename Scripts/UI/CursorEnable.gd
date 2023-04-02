extends Node


func _ready():
	Utilities.center_mouse(get_tree().get_root())
	yield(get_tree().create_timer(1), "timeout") # release the mouse cursor after fade or any other case
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
