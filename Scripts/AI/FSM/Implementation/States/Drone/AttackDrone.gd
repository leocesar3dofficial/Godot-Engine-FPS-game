extends State


export var move_speed: float = 4
export var rotation_speed: float = 4
export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
var manager: StateManager
export(PackedScene) var projectile
export var fire_rate: float = 1
export(Array, NodePath) var fire_points_paths
var fire_points: Array = Array() # initialize array to make it local!
export(NodePath) var audio_player_path
var audio_player: AudioStreamPlayer3D
export(Resource) var gun_fire_sound_effect
export var dont_come_close: float = 4
export(int) var field_of_view = 90
var time: float = 0
var time_to_fire: float = 0
var velocity: Vector3 = Vector3()
var distance: float = INF
var directions: Array
var current_evade_direction: Vector3
var angle: float = 0
export var use_object_pooling: bool = false
export var pool_name: String = "PoolingProjectileEnemy"
var pool: ObjectPooling
var previous_target_position: Vector3
var target_direction: Vector3
var predicted_target_position: Vector3


func _ready():
	# calls base class _ready function first automatically, Godot developers may change this behavior in the future
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)
	audio_player = get_node(audio_player_path)

	for path in fire_points_paths:
		fire_points.append(get_node(path))

	if use_object_pooling:
		pool = get_node("/root/Level/" + pool_name)


func _enter():
	directions = [top_node.global_transform.basis.z, top_node.global_transform.basis.x, -top_node.global_transform.basis.x, Vector3.UP]
	current_evade_direction = directions[randi() % directions.size()]


func _tick(delta: float):
	time += delta

	if is_instance_valid(manager.target) and is_instance_valid(top_node):
		distance = top_node.global_transform.origin.distance_to(manager.target_last_position)

		if distance > dont_come_close:
			var forward: Vector3 = -top_node.global_transform.basis.z
			velocity = forward * move_speed
		else:
			velocity = current_evade_direction * move_speed * 2

		velocity = Utilities.move_towards_free(top_node, manager.target_last_position, velocity, rotation_speed, delta)
		angle = Utilities.angle(top_node, manager.target)

		if time > time_to_fire and angle < (field_of_view / 2):
			time_to_fire = time + (1 / fire_rate)
			fire()

		previous_target_position = manager.target.global_transform.origin


func _exit():
	manager.velocity = velocity


func fire() -> void:
	var point = fire_points[randi() % fire_points.size()]
	var p

	if use_object_pooling:
		p = pool.retrieve_instance()
	else:
		p = projectile.instance()
		get_tree().get_current_scene().add_child(p)

	if p != null:
		target_direction = (manager.target.global_transform.origin - previous_target_position).normalized()
		predicted_target_position = manager.target.global_transform.origin + target_direction * (distance / rotation_speed)
		p.set_translation(point.global_transform.origin)
		p.look_at(predicted_target_position, point.global_transform.basis.y)
		audio_player.stream = gun_fire_sound_effect
		audio_player.play()
