extends Spatial


export(NodePath) var base_path
var turret_base: Spatial
export(NodePath) var barrel_path
var turret_barrel: Spatial
export(NodePath) var target_path
var target: Spatial = null
export var rotation_speed: float = 6
export var min_barrel_x: float = 260.0
export var max_barrel_x: float = 350.0
var desired_rotation: Transform
var temp_quat: Quat


func _ready():
	turret_base = get_node(base_path)
	turret_barrel = get_node(barrel_path)
	target = get_node(target_path)


func _process(delta):
	rotate_towards(target, delta)


func rotate_towards(_target, delta):
	desired_rotation = turret_base.global_transform.looking_at(_target.global_transform.origin, turret_base.global_transform.basis.y)
	temp_quat = Quat(turret_base.global_transform.basis.orthonormalized().get_rotation_quat()).slerp(desired_rotation.basis.orthonormalized().get_rotation_quat(), rotation_speed * delta)
	turret_base.global_transform.basis = Basis(temp_quat)
	turret_base.rotation.x = 0
	turret_base.rotation.z = 0
	turret_base.orthonormalize()

	desired_rotation = turret_barrel.global_transform.looking_at(_target.global_transform.origin, turret_barrel.global_transform.basis.x)
	temp_quat = Quat(turret_barrel.global_transform.basis.orthonormalized().get_rotation_quat()).slerp(desired_rotation.basis.orthonormalized().get_rotation_quat(), rotation_speed * delta)
	turret_barrel.global_transform.basis = Basis(temp_quat)
	turret_barrel.rotation.y = 0
	turret_barrel.rotation.z = 0
	turret_barrel.rotation.x = clamp(turret_barrel.rotation.x, min_barrel_x, max_barrel_x)
	turret_barrel.orthonormalize()
