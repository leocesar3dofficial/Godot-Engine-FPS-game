extends Turret


export(NodePath) var laser_mesh_spatial_path
var laser_mesh: Spatial
export(NodePath) var audio_player_path
var audio_player: AudioStreamPlayer3D
export(Resource) var gun_fire_sound_effect
export var time_visible: float = 1
export var laser_scale_factor: float = 5
export var damage_amount: int = 10
export(PackedScene) var projectile_hit
var can_fire: bool = true
var next_visible_mesh: float = 0
var ph: Node


func _ready():
	# calls base class _ready function first automatically, Godot developers may change this behavior in the future
	laser_mesh = get_node(laser_mesh_spatial_path)
	laser_mesh.set_visible(false)
	audio_player = get_node(audio_player_path)


# warning-ignore:unused_argument
func _process(delta):
	# calls base class _process function first automatically, Godot developers may change this behavior in the future

	if not can_fire and time > next_visible_mesh:
		next_visible_mesh = time + time_visible
		laser_mesh.set_visible(false)
		can_fire = true


func _fire():
	# override base class function
	if can_fire and time > next_visible_mesh:
		next_visible_mesh = time + time_visible
		laser_mesh.set_visible(true)
		can_fire = false
		cast_beam()
		audio_player.stream = gun_fire_sound_effect
		audio_player.play()


func cast_beam():
	var space: PhysicsDirectSpaceState = top_node.get_world().direct_space_state
	var hit: Dictionary = space.intersect_ray(laser_mesh.global_transform.origin, -laser_mesh.global_transform.basis.z * 1000, [top_node], layer_mask)

	if hit:
		var distance: float = laser_mesh.global_transform.origin.distance_to(hit.collider.global_transform.origin)
		laser_mesh.set_scale(Vector3(1, 1, distance * laser_scale_factor))

		if hit.collider.get_collision_layer() == area_node.get_collision_mask():
			hit.collider.get_child(0).apply_damage(damage_amount, -turret_barrel.get_global_transform().basis.z)

		ph = projectile_hit.instance()
		get_tree().get_current_scene().add_child(ph)
		Utilities.start_particle_system(ph)
		ph.set_translation(hit.position)
		var look_normal = hit.position + hit.normal
		ph.look_at(look_normal, laser_mesh.global_transform.basis.y)
	else:
		laser_mesh.set_scale(Vector3(0.001, 0.001, 0.001))
