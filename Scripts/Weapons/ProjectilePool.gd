extends RayCast


export var normal_hit_pool_name: String = "PoolingNormalHit"
export var damage_hit_pool_name: String = "PoolingDamageHit"
export var speed: float = 20
export var collide_with_layer_value: int = 4
export var damage_amount: int = 10
export var time_to_destroy: int = 2
export var pool_name: String = "PoolingProjectileEnemy"
var player: bool = false
var ph: Node
var pool: ObjectPooling
var normal_hit_pool: ObjectPooling
var damage_hit_pool: ObjectPooling
var timer: BasicTimer = BasicTimer.new()
var audio_player: AudioStreamPlayer3D


func _ready():
	timer.time = time_to_destroy
	pool = get_node("/root/Level/" + pool_name)
	normal_hit_pool = get_node("/root/Level/" + normal_hit_pool_name)
	damage_hit_pool = get_node("/root/Level/" + damage_hit_pool_name)
	audio_player = $AudioStreamPlayer3D

	if player:
		damage_amount *= Settings.damage_multiplier


func _process(delta):
	if timer.test(delta):
		timer.reset()
		pool.devolve_instance(self)

	self.translate_object_local(Vector3.FORWARD * speed * delta)

	if is_colliding():
		var collider = get_collider()

		if is_instance_valid(collider):
		# hit player layer (value: 2) or enemy (value: 4)?
			if collider.get_collision_layer() == collide_with_layer_value:
				collider.get_child(0).apply_damage(damage_amount, -get_global_transform().basis.z, player)
				ph = damage_hit_pool.retrieve_instance()
			else:
				ph = normal_hit_pool.retrieve_instance()

			if ph != null:
				ph.play_sound()
				Utilities.start_particle_system(ph)
				ph.set_translation(get_collision_point())
				var look_normal = get_collision_point() + get_collision_normal()
				ph.look_at(look_normal, global_transform.basis.y)
				timer.reset()

		pool.devolve_instance(self)


func play_sound():
	audio_player.play()
