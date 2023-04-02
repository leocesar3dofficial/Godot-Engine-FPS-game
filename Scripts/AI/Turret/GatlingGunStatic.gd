extends Spatial


export(NodePath) var top_node_path
var top_node: Spatial
export(NodePath) var area_node_path
var area_node: Area
export var fire_rate: float = 3
export(NodePath) var fire_point_path
var fire_point: Spatial
export(Resource) var gun_fire_sound_effect
export(PackedScene) var projectile
export (int, FLAGS, "General", "Player", "Enemy", "Pickup", "InvisibleWall", "Prop") var layer_mask = 2^1 + 2^2 # general and player layers
export(NodePath) var audio_player_path
var audio_player: AudioStreamPlayer3D
var time_to_fire: float = 0
export(int) var search_target_time = 2
export(int) var attack_range = 5
export(int) var field_of_view = 90
export(float) var probability_to_fire = 0.5
export var auto_orient: bool = true
export var use_object_pooling: bool = false
export var pool_name: String = "PoolingProjectileEnemy"
var pool: ObjectPooling
var target: Spatial = null
var time_to_search_target: float = 0
var time: float = 0
var distance_from_target: float = 0
var angle: float = 0
var timer: BasicTimer = BasicTimer.new()
var previous_target_position: Vector3
var target_direction: Vector3
var predicted_target_position: Vector3


func _ready():
	top_node = get_node(top_node_path)
	area_node = get_node(area_node_path)
	fire_point = get_node(fire_point_path)
	time_to_search_target = search_target_time
	audio_player = get_node(audio_player_path)
	timer.time = search_target_time

	if use_object_pooling:
		pool = get_node("/root/Level/" + pool_name)


func _process(delta):
	time += delta
	check_target()

	if timer.test(delta):
		target = null
		timer.reset()


func _fire():
	if time > time_to_fire:
		if auto_orient:
			target_direction = (target.global_transform.origin - previous_target_position).normalized()
			predicted_target_position = target.global_transform.origin + target_direction * (distance_from_target / 60)
			fire_point.look_at(predicted_target_position, global_transform.basis.y)

		time_to_fire = time + (1 / fire_rate)
		var p

		if use_object_pooling:
			p = pool.retrieve_instance()
		else:
			p = projectile.instance()
			get_tree().get_current_scene().add_child(p)

		if p != null:
			p.global_transform = fire_point.global_transform
			p.orthonormalize()

			if p is RigidBody:
				p.linear_velocity = -top_node.global_transform.basis.z * attack_range / 3

			p.play_sound()
			audio_player.stream = gun_fire_sound_effect
			audio_player.play()


func check_target() -> void:
	if randf() < probability_to_fire:
		if is_instance_valid(target):
			distance_from_target = top_node.global_transform.origin.distance_to(target.global_transform.origin)
			angle = Utilities.angle(top_node, target)

			if distance_from_target < attack_range and angle < (field_of_view / 2):
				var space: PhysicsDirectSpaceState = get_world().direct_space_state
				var hit: Dictionary = space.intersect_ray(fire_point.global_transform.origin, \
				target.global_transform.origin, \
				[top_node], layer_mask)

				if hit:
					if hit.collider == target:
						_fire()

			previous_target_position = target.global_transform.origin
		else:
			target = Utilities.find_nearest_target_in_sphere(top_node, area_node)
