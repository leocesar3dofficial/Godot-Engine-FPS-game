extends Spatial


export var height: float = 10
export var speed: float = 2
var target: Spatial = null
var camera: Camera = null


func _ready():
	camera = get_viewport().get_camera()


func _process(delta):
	if is_instance_valid(target):
		translation = translation.linear_interpolate(target.global_transform.origin + target.global_transform.basis.y * height, delta * speed)
		Utilities.rotate_towards_free(camera, target.global_transform.origin, speed * 2, delta)
	else:
		target = null
