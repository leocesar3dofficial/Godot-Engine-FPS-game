extends Spatial


export var damage_amount: int = 10
export var enemy_layer = 4
export var player: bool = false
export(PackedScene) var projectile_hit
var can_collide: bool = false
onready var area: Area = $Area
var ph: Node
onready var ray: RayCast = $RayCast as RayCast


func _ready():
	if player:
		damage_amount *= Settings.damage_multiplier

	Utilities.start_particle_system(self)


func _process(_delta):
	if not can_collide:
		return

	var hits = area.get_overlapping_bodies()

	if hits.size() > 0:
		can_collide = false

		for collider in hits:
			if is_instance_valid(collider):
				if collider.collision_layer == enemy_layer:
					collider.get_child(0).apply_damage(damage_amount, -global_transform.basis.z, player)
				elif collider.is_in_group("Switch"):
					collider.activate_switch()

	if ray.enabled and ray.is_colliding():
		ray.enabled = false
		ph = projectile_hit.instance()
		get_tree().get_current_scene().add_child(ph)
		Utilities.start_particle_system(ph)
		ph.set_translation(ray.get_collision_point() + (ray.get_collision_normal() * 1.5))


func _on_Timer_timeout():
	queue_free()


func _on_TimerReadyToDamage_timeout():
	can_collide = true
	ray.enabled = true


