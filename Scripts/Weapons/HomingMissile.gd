extends KinematicBody


export var speed: float = 350
export var steer_force: float = 50
export(NodePath) var detect_target_area_path
var detect_target_area: Area
export(PackedScene) var projectile_hit
export var damage_amount: int = 20
var ph: Node
var velocity: Vector3 = Vector3.ZERO
var acceleration: Vector3 = Vector3.ZERO
var target: Spatial = null
var hit: KinematicCollision
var can_seek: bool = false


func _ready():
	detect_target_area = get_node(detect_target_area_path)


func seek():
	var steer = Vector3.ZERO

	# avoid "previously freed instance" error
	if is_instance_valid(target):
		var direction: Vector3 = (target.global_transform.origin - global_transform.origin)
		steer = (direction - velocity).normalized() * steer_force

	return steer


func _process(delta):
	if can_seek and is_instance_valid(target):
		acceleration += seek()
		velocity += acceleration * speed
		look_at(target.global_transform.origin, Vector3.UP)
	else:
		velocity += -global_transform.basis.z * speed
		if target == null: target = Utilities.find_nearest_target_in_sphere(self, detect_target_area)

	hit = move_and_collide(velocity * delta)

	if hit:
		explode()


func explode():
	if projectile_hit:
		ph = projectile_hit.instance()
		get_tree().get_current_scene().add_child(ph)
		Utilities.start_particle_system(ph)
		ph.set_translation(global_transform.origin)

	queue_free()


func _on_Area_missile_body_entered(body):
	body.get_child(0).apply_damage(damage_amount, -get_global_transform().basis.z)
	explode()


func _on_TimerSeek_timeout():
	can_seek = true


func _on_TimerDestroy_timeout():
	explode()
