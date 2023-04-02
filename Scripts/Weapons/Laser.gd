extends Spatial


export(PackedScene) var projectile_hit
export(NodePath) var raycast_path
export var damage_amount: int = 10
export var enemy_layer = 4
var player: bool = false
var ph: Node
var can_hit: bool = true
var ray: RayCast


func _ready():
	ray = get_node(raycast_path)
	$Timer.connect("timeout", self, "_on_Timer_timeout") # warning-ignore:return_value_discarded
	$TimerHitInterval.connect("timeout", self, "_on_TimerHitInterval_timeout") # warning-ignore:return_value_discarded

	if player:
		damage_amount *= Settings.damage_multiplier


func _process(_delta):
	if can_hit and ray.is_colliding():
		var collider = ray.get_collider()

		if not is_instance_valid(collider):
			return

		can_hit = false

		if collider.collision_layer == enemy_layer:
			collider.get_child(0).apply_damage(damage_amount, -get_global_transform().basis.z, player)
		elif collider.is_in_group("Switch"):
			collider.activate_switch()

		ph = projectile_hit.instance()
		get_tree().get_current_scene().add_child(ph)
		Utilities.start_particle_system(ph)
		ph.set_translation(ray.get_collision_point())
		var look_normal = ray.get_collision_point() + ray.get_collision_normal()
		ph.look_at(look_normal, global_transform.basis.y)


func _on_Timer_timeout():
	queue_free()


func _on_TimerHitInterval_timeout():
	can_hit = true
