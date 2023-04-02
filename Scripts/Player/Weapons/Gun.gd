extends Spatial
class_name Gun


var gun_id: int
export(NodePath) var audio_player_path
var audio_player: AudioStreamPlayer3D
export(NodePath) var gun_point_path
var gun_point : Spatial
export(NodePath) var muzzle_flash_path
export(NodePath) var recoil_path
export(NodePath) var player_camera_path
export(NodePath) var armory_path
var muzzle_flash : Particles
export(Resource) var gun_fire_sound_effect
export(Resource) var gun_fire_sound_effect_secondary
export(PackedScene) var projectile
export(PackedScene) var projectile_secondary
export var fire_rate: float = 1
export var fire_rate_secondary: float = 4
export var spread_angle: float = 15
export var cost: float = 0.25
export var recoil_amount: float = 0.05
export var gun_upgrades: int = 7
var time: float = 0
var time_to_fire: float = 0
var recoil: Recoil
onready var armory: Armory = get_node(armory_path)
var player_camera: Camera
onready var top_node = get_owner()
var power_up_factor: float = 1.1


func _ready():
	gun_id = get_index()
	player_camera = get_node(player_camera_path)
	muzzle_flash = get_node_or_null(muzzle_flash_path)
	gun_point = get_node_or_null(gun_point_path)
	recoil = get_node_or_null(recoil_path)
	audio_player = get_node(audio_player_path)


func _tick(delta):
	time += delta

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if time > time_to_fire and (Input.is_action_pressed("fire") or Input.is_action_just_released("fire")):
			if armory.ammo > 0:
				fire(projectile)
				armory.ammo -= cost

				if armory.ammo < 0:
					armory.ammo = 0

				_gun_fx(fire_rate)
				audio_player.stream = gun_fire_sound_effect
				audio_player.play()
			else:
				armory.out_of_ammo()

			return

		if time > time_to_fire and (Input.is_action_pressed("fire2") or Input.is_action_just_released("fire2")):
			if armory.ammo > 0:
				fire(projectile_secondary)
				armory.ammo -= cost * 3

				if armory.ammo < 0:
					armory.ammo = 0

				_gun_fx(fire_rate_secondary)
				audio_player.stream = gun_fire_sound_effect_secondary
				audio_player.play()
			else:
				armory.out_of_ammo()


func fire(_projectile: PackedScene) -> void:
	Events.emit_signal("update_ammo_bar", armory.ammo)
	var p: Spatial = _projectile.instance()
	p.player = true # the game player shot this projectile (level objectives)
	get_tree().get_current_scene().add_child(p)
	p.global_transform = gun_point.global_transform
	p.rotate_object_local(gun_point.global_transform.basis.x, deg2rad(rand_range(spread_angle / 2, -(spread_angle / 2))))
	p.rotate_object_local(gun_point.global_transform.basis.y, deg2rad(rand_range(spread_angle / 2, -(spread_angle / 2))))
	recoil.start_recoil(recoil_amount, -recoil_amount, recoil_amount, 20)

	if Settings.knockback:
		top_node.velocity += player_camera.global_transform.basis.z * recoil_amount * 40 # gun knockback

	Events.emit_signal("camera_shaked", recoil_amount * 2)


func _gun_fx(_fire_rate: float) -> void:
	muzzle_flash.emitting = true
	muzzle_flash.restart()
	time_to_fire = time + (1 / _fire_rate)


func power_up():
	if gun_upgrades > 0:
		gun_upgrades -= 1
		fire_rate *= power_up_factor
		fire_rate_secondary *= power_up_factor
		spread_angle /= power_up_factor
		cost /= power_up_factor
