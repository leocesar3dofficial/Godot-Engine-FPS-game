extends RayCast


export var speed: float = 3
export(NodePath) var detect_target_area_path
var detect_target_area: Area
export(PackedScene) var projectile_hit
export var damage_amount: float = 20
export var enemy_layer = 4
export(NodePath) var bornFX_path
var bornFX: Spatial
export var player: bool = false
var ph: Node
var velocity: Vector3 = Vector3.ZERO


func _ready():
	bornFX = get_node(bornFX_path)
	detect_target_area = get_node(detect_target_area_path)

	if bornFX:
		Utilities.start_particle_system(bornFX)


	if player:
		damage_amount *= Settings.damage_multiplier


func _process(delta):
	velocity += Vector3.FORWARD * speed * delta
	translate_object_local(velocity)

	if is_colliding():
		var collider = get_collider()

		if is_instance_valid(collider):
			if collider.collision_layer == enemy_layer:
				collider.get_child(0).apply_damage(damage_amount, -global_transform.basis.z, player)
			elif collider.is_in_group("Switch"):
				collider.activate_switch()

		explode()


func explode():
	var bodies: Array = detect_target_area.get_overlapping_bodies()

	for b in bodies:
		# calculate damage amount by distance from the grenade for each body inside the area
		var distance: float = self.global_transform.origin.distance_to(b.global_transform.origin)
		damage_amount *= clamp(1 - (distance / detect_target_area.get_child(0).shape.radius), 0.05, 1)
		b.get_child(0).apply_damage(damage_amount, Vector3.UP, player)

	if projectile_hit:
		ph = projectile_hit.instance()
		get_tree().get_current_scene().add_child(ph)
		Utilities.start_particle_system(ph)
		ph.set_translation(global_transform.origin)
		ph.scale = Vector3.ONE * 3

	queue_free()


func _on_Timer_timeout():
	explode()


