extends Node


export(PackedScene) var die_effect
export var die_effect_scale: float = 1
export(NodePath) var area_path
export var damage_amount: float = 20
export var explosion_force: float = 0.05
onready var area: Area = get_node(area_path)
var distance: float = 0
var can_die: bool = true


func _ready():
	$Timer.connect("timeout", self, "_on_Timer_timeout") # warning-ignore:return_value_discarded
	$Timer.wait_time = $Timer.wait_time + ($Timer.wait_time * randf())


func initiate_custom_death():
	if can_die:
		can_die = false
		owner.apply_impulse(owner.global_transform.origin, owner.global_transform.basis.y * (Vector3.UP * explosion_force))
		$Timer.start()


func _on_Timer_timeout():
	var de = die_effect.instance()
	get_tree().get_current_scene().add_child(de)
	Utilities.start_particle_system(de)
	de.global_transform.origin = owner.global_transform.origin
	de.scale = Vector3.ONE * die_effect_scale

	var bodies = area.get_overlapping_bodies()

	for b in bodies:
		# calculate damage amount by distance from the barrel for each body inside the area
		distance = owner.global_transform.origin.distance_to(b.global_transform.origin)
		damage_amount *= clamp(1 - (distance / area.get_child(0).shape.radius), 0.05, 1)

		if b is RigidBody:
			b.apply_impulse(b.global_transform.origin, Vector3.UP * explosion_force)

		b.get_child(0).apply_damage(damage_amount, Vector3.UP, false)

	get_owner().queue_free()
