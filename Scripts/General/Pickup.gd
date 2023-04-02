extends RigidBody


enum PickupType {SPRINT, JUMP, AMMO, HEALTH}

export var force: float = 6
export(PackedScene) var dieFX
export(PickupType) var pickup_type = 0


func _ready():
	linear_velocity = Vector3(rand_range(0, force), rand_range(0, force), rand_range(0, force))
	angular_velocity = Vector3(rand_range(0, force), rand_range(0, force), rand_range(0, force))


func _on_Area_body_entered(body):
	if body.name == "Player":
		match pickup_type:
			PickupType.SPRINT:
				body.increase_sprint(33)
			PickupType.JUMP:
				body.increase_jump(33)
			PickupType.AMMO:
				Events.emit_signal("increase_amno", 33)
			PickupType.HEALTH:
				body.get_child(0).increase_hit_points(33)

		start_fx()
		queue_free()


func _on_Timer_timeout():
	start_fx()
	queue_free()


func start_fx():
	Events.emit_signal("camera_shaked", 0.2)
	var fx = dieFX.instance()
	get_tree().get_current_scene().add_child(fx)
	fx.global_transform.origin = self.global_transform.origin
	fx.scale = Vector3.ONE / 2
	Utilities.start_particle_system(fx)
