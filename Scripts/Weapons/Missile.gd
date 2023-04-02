extends KinematicBody


export var speed: float = 3
export(NodePath) var detect_target_area_path
var detect_target_area: Area
export(PackedScene) var projectile_hit
export var damage_amount: int = 20
var ph: Node
var velocity: Vector3 = Vector3.ZERO
var hit: KinematicCollision

func _ready():
	detect_target_area = get_node(detect_target_area_path)


func _process(delta):
	velocity += -global_transform.basis.z * speed * delta
	hit = move_and_collide(velocity)

	if hit:
		explode()


func explode():
	if projectile_hit:
		ph = projectile_hit.instance()
		get_tree().get_current_scene().add_child(ph)
		Utilities.start_particle_system(ph)
		ph.set_translation(global_transform.origin)
		ph.scale = Vector3.ONE * 3
		
	queue_free()


func _on_Area_missile_body_entered(body):
	body.get_child(0).apply_damage(damage_amount, -get_global_transform().basis.z)
	explode()


func _on_Timer_timeout():
	explode()


