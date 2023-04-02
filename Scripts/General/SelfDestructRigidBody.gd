extends RigidBody

export var apply_force: bool = true
export var force: float = 6
var can_destroy: bool = false
export(NodePath) var born_fx_path
var born_fx: Spatial


func _ready():
	if not born_fx_path.is_empty():
		born_fx = get_node(born_fx_path)
		Utilities.start_particle_system(born_fx)
	
	if apply_force:
		linear_velocity = Vector3(rand_range(0, force), rand_range(0, force), rand_range(0, force))
		angular_velocity = Vector3(rand_range(0, force), rand_range(0, force), rand_range(0, force))


func _on_Timer_timeout():
	can_destroy = true


func _on_VisibilityNotifier_screen_exited():
	if can_destroy:
		self.queue_free()
