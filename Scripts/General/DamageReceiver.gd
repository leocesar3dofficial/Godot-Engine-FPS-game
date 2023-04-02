extends Node
class_name DamageReceiver


export(NodePath) var movement_node_path
var movement_node: Node
export(Array, NodePath) var hit_meshes_paths
var hit_meshes: Array = Array() # initialize array to make it local!
export(Resource) var blink_material
export var blink_surface_index: int = 0
export(PackedScene) var die_effect
export var hit_points: float = 10
export var slam_back_force: float = 10
export var die_effect_offset: float = 0.5
export var damage_other_when_die: bool = false
export(NodePath) var other_path
export var other_damage_amount: int = 1
export var destroy_me: bool = true
export(NodePath) var audio_player_path
export(NodePath) var animation_tree_path
var audio_player: AudioStreamPlayer3D
export(Array, Resource) var grunts
export(UnitsManager.UnitsType) var enum_unit_type = UnitsManager.UnitsType.GENERAL
var dead: bool = false
var slam_back_flag: bool = true
var hit_meshes_materials: Array = Array()
var blink_flag: bool = true
var de: Spatial
var next_slam_back: float = 0
var next_blink: float = 0
var elapsed: float = 0
var units_manager: UnitsManager
var can_damage: bool = true
var destroy_timer: BasicTimer = BasicTimer.new()
var self_delta: float = 0
export var die_effect_scale: float = 2
export var wait_time_to_free: float = 0.3
var initial_hit_points: float
export var god_mode: bool = false
var player_instance: bool = false
var animation_tree: AnimationTree
var parent: Node
export var time_to_hit: float = 0.3


func _ready():
	Events.connect("player_entered_scene", self, "_on_player_entered_scene") # warning-ignore:return_value_discarded
	parent = get_parent()
	units_manager = get_node("/root/Level/UnitsManager")
	units_manager.update_units(enum_unit_type, 1)
	initial_hit_points = hit_points
	destroy_timer.time = wait_time_to_free # time to queue_free() this entity
	audio_player = get_node_or_null(audio_player_path)

	if owner.name == "Player": player_instance = true # real player?
	if movement_node_path: movement_node = get_node(movement_node_path)
	if animation_tree_path: animation_tree = get_node(animation_tree_path)

	for path in hit_meshes_paths:
		hit_meshes.append(get_node(path))

	for i in range(hit_meshes.size()):
		hit_meshes_materials.insert(i, hit_meshes[i].get_surface_material(0))

	yield(get_tree(), "idle_frame")
	Events.emit_signal("add_pointer", parent, enum_unit_type)


func _process(delta):
	if not can_damage and destroy_timer.test(delta):
		if is_instance_valid(parent) and not player_instance:
			parent.queue_free()
			return

	if dead and parent is KinematicBody:
		parent.move_and_slide((parent.global_transform.basis.z * slam_back_force) + (Vector3.UP * slam_back_force / 3), Vector3.UP)

	elapsed += delta

	if elapsed > next_slam_back and slam_back_flag == false:
		slam_back_flag = true

	# reassign original materials to the hit meshes
	if elapsed > next_blink and blink_flag == false:
		for i in range(hit_meshes.size()):
			hit_meshes[i].set_surface_material(blink_surface_index, hit_meshes_materials[i])

		blink_flag = true


func damage(amount: float, player: bool = false) -> void:
	if can_damage:
		if player and randf() < 0.1: Events.emit_signal("bullet_time")
		Events.emit_signal("camera_shaked")
		hit_points -= amount

		if not dead and hit_points < 1:
			dead = true
			hit_points = 0

			if not player_instance: # remove pointer from gyroscope
				units_manager.update_units(enum_unit_type, -1)
				Events.emit_signal("remove_pointer", parent)

		if dead:
			can_damage = false

			# killed by player projectile?
			if player:
				Jukebox.crossfade_music() # play battle music

				if enum_unit_type == UnitsManager.UnitsType.ENEMY:
					units_manager.enemy_destroyed()

			if not destroy_me:
				set_process(false)
				get_child(0).initiate_custom_death()

			# real player dead?
			if player_instance:
				if not BackgroundLoader.can_load_scene:
					return

				Jukebox.crossfade_music(false)
				BackgroundLoader.fade_in_out()
				BackgroundLoader.play_badge(1, 3)
				var player_factory = get_node("/root/Level/PlayerFactory")
				yield(get_tree().create_timer(0.5) , "timeout")
				parent.set_name("OldPlayer")

				if SaveLoadGame.save_game_file_exists()\
					and (SaveLoadGame.checkpoint_level + 1) == BackgroundLoader.levels.find(get_node("/root/Level/").filename)\
					and SaveLoadGame.checkpoint_position != Vector3.ZERO:
					player_factory.create_player(PlayerFactory.PlayerType.PLAYER, SaveLoadGame.checkpoint_position, player_factory.rotation)
					parent.queue_free()
				else:
					get_tree().reload_current_scene() # warning-ignore:return_value_discarded
			else:
				if damage_other_when_die:
					if other_path: # node assigned in inspector
						get_node(other_path).get_child(0).apply_damage(other_damage_amount, Vector3.UP, player)
					else: # apply damage to the parent's owner
						get_parent().get_owner().get_child(0).apply_damage(other_damage_amount, Vector3.UP, player)

				if die_effect:
					if movement_node and animation_tree: # delay queue_free
						movement_node.set_process(false)
						var playback = animation_tree["parameters/playback"]
						playback.travel("Death")
						create_dying_effect(wait_time_to_free * 0.8)
					else: # immediately queue_free
						_on_create_dying_effect()
		else:
			blink()

		if player_instance:
			BackgroundLoader.DoGlitch()
			Events.emit_signal("update_health_bar", (hit_points / initial_hit_points) * 100)
			Events.emit_signal("camera_shaked", 0.2)

		if audio_player and grunts.size() > 0:
			audio_player.stream = grunts[randi() % grunts.size()]
			audio_player.play()


func increase_hit_points(amount: int) -> void:
	if not dead:
		hit_points += amount

		if hit_points > initial_hit_points:
			hit_points = initial_hit_points

		Events.emit_signal("update_health_bar", (hit_points / initial_hit_points) * 100)


func apply_damage(damage_amount: float, direction: Vector3, player: bool = false) -> void:
	if god_mode:
		return

	if slam_back_flag:
		slam_back_flag = false
		next_slam_back = elapsed + time_to_hit # wait for given time before get hit again
		damage(damage_amount, player)

		if movement_node:
			if player_instance and Settings.knockback == false:
				return;

			movement_node.velocity = parent.move_and_slide((direction.normalized() * slam_back_force) + (Vector3.UP * slam_back_force / 2), Vector3.UP)


func blink() -> void:
	if hit_meshes.size() > 0 and blink_flag:
		blink_flag = false

		# assign blink material (emissive) to the hit meshes
		for mesh in hit_meshes:
			mesh.set_surface_material(blink_surface_index, blink_material)

		next_blink = elapsed + time_to_hit * 0.5 # wait for given time (half the time to hit) before blink again


func create_dying_effect(delay: float):
	"""
	Create a timer node instead of using yield to avoid the error:
	Resumed function after yield, but class instance is gone.
	This error crashes the exported game!
	"""
	var timer: Timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", self, "_on_create_dying_effect") # warning-ignore:return_value_discarded
	timer.start(delay)


func _on_create_dying_effect():
	de = die_effect.instance()
	get_tree().get_current_scene().add_child(de)
	Utilities.start_particle_system(de)
	de.global_transform.origin = parent.global_transform.origin + (parent.global_transform.basis.y.normalized() * die_effect_offset)
	de.scale = Vector3.ONE * die_effect_scale


func _on_player_entered_scene():
	if not dead:
		Events.emit_signal("add_pointer", parent, enum_unit_type)


func _exit_tree():
	Events.emit_signal("remove_pointer", parent)
	units_manager.update_units(enum_unit_type, -1)
