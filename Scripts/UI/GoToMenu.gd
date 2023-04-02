extends Control


export(String, FILE) var scene_path: String


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	yield(get_tree().create_timer(4), "timeout")
	BackgroundLoader.load_scene(scene_path)
