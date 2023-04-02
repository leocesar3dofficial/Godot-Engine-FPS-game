extends RayCast


export(PackedScene) var projectile_hit
export(PackedScene) var projectile_damage
export var speed: float = 20
export var collide_with_layer_value: int = 4
export var damage_amount: int = 10
var player: bool = false # did the game player shoot this projectile?
var ph: Node
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready():
	if player:
		damage_amount *= Settings.damage_multiplier


func _process(delta):
	self.translate_object_local(Vector3.FORWARD * speed * delta)

	if is_colliding():
		var collider : Spatial = get_collider()

		if not is_instance_valid(collider):
			return

		# hit player layer (value: 2) or enemy (value: 4)?
		if collider.get_collision_layer() == collide_with_layer_value:
			collider.get_child(0).apply_damage(damage_amount, -get_global_transform().basis.z, player)
			ph = projectile_damage.instance()
		else:
			ph = projectile_hit.instance()

			if player and collider.is_in_group("Switch"):
				collider.activate_switch()

		get_tree().get_current_scene().add_child(ph)
		Utilities.start_particle_system(ph)
		ph.set_translation(get_collision_point())
		var look_normal = get_collision_point() + get_collision_normal()
		ph.look_at(look_normal, global_transform.basis.y)
		queue_free()


func _on_Timer_timeout():
	self.queue_free()


func play_sound():
	audio_player.play()
