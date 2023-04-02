# Prevent 2d controls jittering:
# Disable in Project Settings > General > Gui > Common > Snap Controls To Pixels = false
extends Spatial


export var offset_x: int = 0
export var offset_y: int = 0
export var use_current_camera: bool = true
export(String) var camera_path = "/root/Level/Player/Head/Headbobber/Camera"
var camera: Camera
var tooltip: Control
var screen_point: Vector2


func _ready():
	if use_current_camera:
		camera = get_viewport().get_camera()
	else:
		camera = get_node_or_null(camera_path)

	tooltip = get_child(0)


# warning-ignore:unused_argument
func _process(delta):
	if tooltip.visible:
		if is_instance_valid(camera):
			screen_point = camera.unproject_position(global_transform.origin)
			tooltip.set_position(Vector2(screen_point.x + offset_x, screen_point.y + offset_y), true)
		else:
			if use_current_camera:
				camera = get_viewport().get_camera()
			else:
				camera = get_node_or_null(camera_path)

