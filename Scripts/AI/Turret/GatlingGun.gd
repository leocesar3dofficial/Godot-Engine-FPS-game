extends Turret


export var fire_rate: float = 3
export(Array, NodePath) var fire_points_paths
var fire_points: Array = Array() # initialize array to make it local!
export(Resource) var gun_fire_sound_effect
export(PackedScene) var projectile
var audio_player: AudioStreamPlayer3D
var time_to_fire: float = 0
export var use_object_pooling: bool = false
export var pool_name: String = "PoolingProjectileEnemy"
var pool: ObjectPooling
onready var random_interval: float = 1 + randf()


func _ready():
	audio_player = $AudioStreamPlayer3D

	for fire_point_path in fire_points_paths:
		fire_points.append(get_node(fire_point_path))

	audio_player.stream = gun_fire_sound_effect

	if use_object_pooling:
		pool = get_node("/root/Level/" + pool_name)


func _fire():
	if time > time_to_fire:

		time_to_fire = time + (random_interval / fire_rate)
		var fire_point = fire_points[randi() % fire_points.size()]
		var p

		if use_object_pooling:
			p = pool.retrieve_instance()
		else:
			p = projectile.instance()
			get_tree().get_current_scene().add_child(p)

		if p != null:
			if turret_barrel is RecoilMoveOnly:
				turret_barrel.start_recoil()

			p.global_transform = fire_point.global_transform
			p.orthonormalize()
			audio_player.stream = gun_fire_sound_effect
			audio_player.play()
