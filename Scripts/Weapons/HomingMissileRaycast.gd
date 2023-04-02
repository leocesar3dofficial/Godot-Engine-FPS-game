extends RayCast


export var speed: float = 0.1
export var rotation_speed: float = 4.0
export(NodePath) var detect_target_area_path
var detect_target_area: Area
export(PackedScene) var projectile_hit
export var damage_amount: int = 20
export var collide_with_layer_value: int = 4
export(NodePath) var bornFX_path
var bornFX: Spatial
var player: bool = false
var ph: Node
var target: Spatial = null
var target_distance: float = INF
var can_seek: bool = false
var acceleration: Vector3 = Vector3.ZERO
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready():
	enabled = false # the missile can't hit nothing at birth
	bornFX = get_node(bornFX_path)

	if bornFX:
		Utilities.start_particle_system(bornFX)

	detect_target_area = get_node(detect_target_area_path)

	if player:
		damage_amount *= Settings.damage_multiplier


func _process(delta):
	if can_seek and is_instance_valid(target):
		Utilities.rotate_towards_free(self, target.global_transform.origin, rotation_speed, delta)
		target_distance = global_transform.origin.distance_to(target.global_transform.origin)

		if target_distance < 4.0:
			target.get_child(0).apply_damage(damage_amount, -global_transform.basis.z, player)
			explode()
			return
	else:
		target = Utilities.find_nearest_target_in_sphere(self, detect_target_area)

	acceleration += Vector3.FORWARD * speed * delta
	translate_object_local(acceleration)

	if is_colliding():
		var collider = get_collider()

		if is_instance_valid(collider):
			if collider.get_collision_layer() == collide_with_layer_value:
				collider.get_child(0).apply_damage(damage_amount, -global_transform.basis.z, player)
			elif collider.is_in_group("Switch"):
				collider.activate_switch()

		explode()


func explode():
	ph = projectile_hit.instance()
	get_tree().get_current_scene().add_child(ph)
	Utilities.start_particle_system(ph)
	ph.set_translation(global_transform.origin)
	queue_free()


func _on_TimerSeek_timeout():
	enabled = true # activate target hit detection
	can_seek = true


func _on_TimerDestroy_timeout():
	explode()


func play_sound():
	audio_player.play()
