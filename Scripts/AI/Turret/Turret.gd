extends Spatial
class_name Turret


export(NodePath) var base_path
var turret_base: Spatial
export(NodePath) var barrel_path
var turret_barrel: Spatial
export var rotation_speed: float = 6
export var min_barrel_x: float = 260.0
export var max_barrel_x: float = 350.0
var desired_rotation: Transform
var temp_quat: Quat
export(NodePath) var top_node_path
var top_node: Spatial
export(NodePath) var area_node_path
var area_node: Area
export(int) var search_target_time = 2
export(int) var attack_range = 5
export(int) var gunshot_spread = 90
export var origin_offset: Vector3
export var target_offset: Vector3
export (int, FLAGS, "General", "Player", "Enemy", "Pickup", "InvisibleWall", "Prop") var layer_mask = 2^1 + 2^2 # general and player layers
var target: Spatial = null
#var time_to_search_target: float = 0
var time: float = 0
var distance_from_target: float = 0
var angle: float = 0
var timer: BasicTimer = BasicTimer.new()
var previous_target_position: Vector3
var target_direction: Vector3
var predicted_target_position: Vector3


func _ready():
	_my_ready()


func _my_ready():
	turret_base = get_node(base_path)
	turret_barrel = get_node(barrel_path)
	top_node = get_node(top_node_path)
	area_node = get_node(area_node_path)
	timer.time = search_target_time
	area_node.get_child(0).shape.radius = attack_range


func _process(delta):
	_my_process(delta)


func _my_process(delta: float):
	time += delta

	if is_instance_valid(target) and distance_from_target < attack_range:
		rotate_towards(target, delta)

	check_target()

	if timer.test(delta):
		target = null
		timer.reset()


func rotate_towards(_target, delta):
	target_direction = (_target.global_transform.origin - previous_target_position).normalized()
	predicted_target_position = _target.global_transform.origin + target_direction * (distance_from_target / rotation_speed)
	desired_rotation = turret_base.global_transform.looking_at(predicted_target_position + target_offset, turret_base.global_transform.basis.y)
	temp_quat = Quat(turret_base.global_transform.basis.orthonormalized().get_rotation_quat()).slerp(desired_rotation.basis.orthonormalized().get_rotation_quat(), rotation_speed * delta)
	turret_base.global_transform.basis = Basis(temp_quat)
	turret_base.rotation.x = 0
	turret_base.rotation.z = 0
	turret_base.orthonormalize()

	desired_rotation = turret_barrel.global_transform.looking_at(predicted_target_position + target_offset, turret_barrel.global_transform.basis.x)
	temp_quat = Quat(turret_barrel.global_transform.basis.orthonormalized().get_rotation_quat()).slerp(desired_rotation.basis.orthonormalized().get_rotation_quat(), rotation_speed * delta)
	turret_barrel.global_transform.basis = Basis(temp_quat)
	turret_barrel.rotation.y = 0
	turret_barrel.rotation.z = 0
	turret_barrel.rotation.x = clamp(turret_barrel.rotation.x, min_barrel_x, max_barrel_x)
	turret_barrel.orthonormalize()


func check_target() -> void:
	if is_instance_valid(target):
		distance_from_target = top_node.global_transform.origin.distance_to(target.global_transform.origin)
		angle = Utilities.angle(turret_barrel, target)

		if distance_from_target < attack_range and angle < (gunshot_spread / 2):
			var space: PhysicsDirectSpaceState = get_world().direct_space_state
			var hit: Dictionary = space.intersect_ray(turret_barrel.global_transform.origin + origin_offset, \
			target.global_transform.origin + target_offset, \
			[top_node], layer_mask)

			if hit:
				if hit.collider == target:
					_fire()

		previous_target_position = target.global_transform.origin
	else:
		target = Utilities.find_nearest_target_in_sphere(top_node, area_node)


func _fire() -> void:
	# to override
	pass
