extends KinematicBody


export(PackedScene) var projectile_hit
export(PackedScene) var projectile_damage
export var speed: float = 20
export var collide_with_layer_value: int = 4
export var damage_amount: int = 10
var hit: KinematicCollision
var ph: Node


func _process(delta):
	hit = move_and_collide(-global_transform.basis.z * speed * delta)

	if hit:
		if not hit.collider:
			return

		$CollisionShape.disabled = true
		# hit player layer (value: 2) or enemy (value: 4)?
		if hit.collider.get_collision_layer() == collide_with_layer_value:
			hit.collider.get_child(0).apply_damage(damage_amount, -get_global_transform().basis.z)
			ph = projectile_damage.instance()
		else:
			ph = projectile_hit.instance()

		get_tree().get_current_scene().add_child(ph)
		Utilities.start_particle_system(ph)
		ph.set_translation(hit.position)
		var look_normal = hit.position + hit.normal
		ph.look_at(look_normal, global_transform.basis.y)
		queue_free()


func _on_Timer_timeout():
	self.queue_free()
