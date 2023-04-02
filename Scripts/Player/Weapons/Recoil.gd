extends Spatial
class_name Recoil


export var recoil_time: float = 0.05
export var max_recoil_x: float = -10
export var recoil_speed: float = 5
export var max_recoil_y: float = 20
export var max_recoil_z: float = 0.8


# called in the gun fire method
func start_recoil(recoil_time_param, max_recoil_x_param, max_recoil_y_param, recoil_speed_param) -> void:
	recoil_time = recoil_time_param
	max_recoil_x = max_recoil_x_param
	recoil_speed = recoil_speed_param
	max_recoil_y = rand_range(-max_recoil_y_param, max_recoil_y_param)


func recoiling(delta) -> void:
	if recoil_time > 0:
		var current_rotation = transform.basis.get_rotation_quat()
		current_rotation.set_euler(Vector3(-max_recoil_x, max_recoil_y, 0))
		set_transform(Transform(Quat(transform.basis.orthonormalized()).slerp(current_rotation, recoil_speed * delta), transform.origin))
		translation = Vector3(translation.x, translation.y, lerp(0, max_recoil_z, 0.1) )
		recoil_time -= delta
	else:
		set_transform(Transform(Quat(transform.basis.orthonormalized()).slerp(Quat.IDENTITY, recoil_speed * delta), transform.origin))
		translation = Vector3(translation.x, translation.y, lerp(translation.z, 0, 0.1) )
		recoil_time = 0


func _process(delta):
	recoiling(delta)
