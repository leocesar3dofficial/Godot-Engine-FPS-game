extends Spatial


export(NodePath) var secondary_damage_area_path
export(NodePath) var camera_path
onready var camera: Camera = get_node(camera_path)
export(NodePath) var audio_player_path
onready var audio_player: AudioStreamPlayer3D = get_node(audio_player_path)
export(Resource) var gun_fire_sound_effect
export(Resource) var gun_fire_sound_effect_secondary
export(Resource) var no_hit_sound_effect
export(NodePath) var recoil_path
export(NodePath) var armory_path
onready var gun_id: int = get_index()
onready var level : Spatial = get_node("/root/Level/")
onready var top_node : KinematicBody = get_owner()
export(NodePath) var hook_path
onready var hook : RayCast = get_node(hook_path)
onready var line_helper : Spatial = $LineHelper
export(NodePath) var gun_point_path
onready var gun_point : Spatial = get_node(gun_point_path)
export var max_grapple_speed : float = 2.75
export var grapple_speed : float= 0.5
var hooked : bool = false
var grapple_target_position : Vector3
onready var recoil: Recoil = get_node_or_null(recoil_path)
export var recoil_amount: float = 0.05
var time: float = 0
var time_to_fire: float = 0
export var fire_rate_secondary: float = 4
export(PackedScene) var projectile_secondary
var secondary_projectile_instance : Spatial
onready var secondary_damage_area : Area = get_node(secondary_damage_area_path)
export var secondary_damage : float = 10
onready var armory: Armory = get_node(armory_path) as Armory
export var cost: float = 1
export var gun_upgrades: int = 3
var power_up_factor: float = 1.25


func _ready():
	line_helper.visible = false
	secondary_projectile_instance = projectile_secondary.instance()
	camera.call_deferred("add_child", secondary_projectile_instance)


func _tick(delta):
	time += delta

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		handle_hook()


func handle_hook() -> void:
	check_hook_activation()
	draw_hook(calculate_path())


func check_hook_activation() -> void:
	# Activate hook
	if Input.is_action_just_pressed("fire"):
		if armory.ammo > 0:
			if hook.is_colliding():
				armory.ammo -= cost

				if armory.ammo < 0:
					armory.ammo = 0

				Events.emit_signal("update_ammo_bar", armory.ammo)
				hooked = true
				audio_player.stream = gun_fire_sound_effect
				audio_player.play()
				grapple_target_position = hook.get_collision_point()
				line_helper.visible = true
				top_node.air_time = 0
			else:
				audio_player.stream = no_hit_sound_effect
				audio_player.play()
		else:
			armory.out_of_ammo()

	elif Input.is_action_just_released("fire"):
		hooked = false
		recoil.start_recoil(recoil_amount * 2, -recoil_amount, recoil_amount, 20)
		line_helper.visible = false

	if time > time_to_fire and (Input.is_action_pressed("fire2") or Input.is_action_just_released("fire2")):
		if armory.ammo > 0:
			armory.ammo -= cost * 3

			if armory.ammo < 0:
				armory.ammo = 0

			Events.emit_signal("update_ammo_bar", armory.ammo)
			time_to_fire = time + (1 / fire_rate_secondary)
			Utilities.start_particle_system(secondary_projectile_instance)
			audio_player.stream = gun_fire_sound_effect_secondary
			audio_player.play()
			Events.emit_signal("camera_shaked", 1.0)
			var hits : Array = secondary_damage_area.get_overlapping_bodies()

			for h in hits:
				if h.is_in_group("Switch"):
					h.activate_switch()
				elif h.get_children().size() > 0:
					if h.get_child(0).has_method("apply_damage"):
						h.get_child(0).apply_damage(secondary_damage, Vector3.UP, true)
		else:
			armory.out_of_ammo()


# Adds to player velocity and returns the length of the hook rope
func calculate_path() -> float:
	var player2hook : Vector3 = grapple_target_position - top_node.global_transform.origin # vector from player to hook
	var length : float = player2hook.length()

	if hooked:
		# if we more than 4 away from line, don't dampen speed as much
		if length > 4:
			top_node.velocity *= .999
		# Otherwise dampen speed more
		else:
			top_node.velocity *= .9

		# Hook's law equation
		var force : float = grapple_speed * length

		# Clamp force to be less than max_grapple_speed
		if abs(force) > max_grapple_speed:
			force = max_grapple_speed

		# Preserve direction, but scale by force
		top_node.velocity += player2hook.normalized() * force

	return length


# Makes the line have length LENGTH
func draw_hook(length: float) -> void:
	if hooked:
		line_helper.look_at(grapple_target_position, Vector3.UP)
		line_helper.scale.z = length


func power_up():
	if gun_upgrades > 0:
		gun_upgrades -= 1
		grapple_speed *= power_up_factor
		max_grapple_speed *= power_up_factor
		fire_rate_secondary *= power_up_factor
		secondary_damage *= power_up_factor
		cost /= power_up_factor
