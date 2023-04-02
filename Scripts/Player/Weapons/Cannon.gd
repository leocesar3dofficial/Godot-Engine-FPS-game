extends Gun


export var gun_rotation_angle: float = 0.05
export var gun_rotation_max_speed: float = 0.07
export var gun_rotation_axis: Vector3 = -Vector3.FORWARD
var gun_current_rotation_angle: float = 0
var local_delta: float = 0


func _tick(delta):
	local_delta = delta
	# call super function
	._tick(delta)
	gun_rotation(delta)


func _gun_fx(_fire_rate: float) -> void:
	._gun_fx(_fire_rate)
	gun_current_rotation_angle += (1 + gun_rotation_angle) * local_delta


func gun_rotation(delta: float):
	gun_current_rotation_angle -= gun_rotation_angle * delta
	gun_current_rotation_angle = clamp(gun_current_rotation_angle, 0, gun_rotation_max_speed)
	rotate_object_local(gun_rotation_axis, gun_current_rotation_angle)
