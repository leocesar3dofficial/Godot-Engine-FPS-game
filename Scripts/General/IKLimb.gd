extends Spatial


var target: Spatial
export var height: float = 2.0
export(float) var speed = 2.0
var ray: RayCast
var start: Vector3
var end: Vector3
var time: float = 1.0
export var max_leg_distance: float = 4.0
var distance: float = 0.0
export(NodePath) var opposing_limb_path
var opposing_limb
export var vertical_offset: float = -6
var moving: bool = false
var ik_target: Spatial


func _ready():
	opposing_limb = get_node(opposing_limb_path)
	ik_target = $IKTarget
	ray = $RayCast
	target = Spatial.new()
	var level = get_node("/root/Level")
	level.call_deferred("add_child", target)
	target.translation = ray.get_collision_point()
	end = target.translation
	start = target.translation


func _process(delta):
	time += delta * speed
	
	if target.is_inside_tree():
		distance = (ray.global_transform.origin + Vector3.UP * vertical_offset).distance_to(target.global_transform.origin)
	
		if ray.is_colliding():
			if time > 1.2 and distance > max_leg_distance and not opposing_limb.moving:
				start = target.global_transform.origin
				end = ray.get_collision_point()
				time = 0
	
			if time <= 1:
				moving = true
				target.translation = parabola(start, end, height, time)
			else:
				moving = false
		else:
			moving = false
			target.translation = target.global_transform.origin.linear_interpolate(ray.global_transform.origin + ray.cast_to, delta * speed)
	
		ik_target.global_transform.origin = target.global_transform.origin


func parabola(_start: Vector3, _end: Vector3, _height: float, _time: float) -> Vector3:
	var pos = _start.linear_interpolate(_end, _time)
	pos.y += sin(_time * PI) * _height
	return pos
