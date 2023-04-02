extends VehicleBody


export var engine_force_value: float = 120
export var max_engine_force_value: float = 200
export var steer_limit: float = 0.4
export var steer_speed: float = 1.0
export(PlayerFactory.VehicleType) var vehicle_type
export var exit_player_spawn_height: float = 3
export var exit_vehicle_spawn_height: float = 5
export var running_sfx_speed: float = 5
export var high_sfx_speed: float = 15
export(Resource) var idle_sfx
export(Resource) var running_sfx
export(Resource) var high_speed_sfx
var vehicle_sounds_player: AudioStreamPlayer3D
var grunts_sounds_player: AudioStreamPlayer3D
var steer_angle: float = 0
var steer_target: float = 0
var sprint_gas: float = 100
var jump_gas: float = 100
var default_force_value: float
var inside_vehicle: bool = false
onready var player_factory: PlayerFactory = get_node_or_null("/root/Level/PlayerFactory")
onready var grunts_SFX: Array = get_child(0).grunts
onready var crash_sparks: Array = $Sparks.get_children()


func _ready():
	vehicle_sounds_player = $VehicleSound
	grunts_sounds_player = $Grunts
	default_force_value = engine_force_value

	if Settings.show_debug:
		$DebugInfo.visible = true

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# only car uses the third person camera!
#	if vehicle_type == PlayerFactory.VehicleType.CAR:
#		Events.emit_signal("change_camera", $Target)
	Events.emit_signal("change_camera", $Target)

	Events.emit_signal("update_sprint_bar", sprint_gas)
	Events.emit_signal("player_entered_scene") # tell Points of Interest that the Player is on the scene

	# prevents fast exiting of vehicle
	yield(get_tree().create_timer(3), "timeout")
	inside_vehicle = true


func _process(delta):
	# sprinting
	if Input.is_action_pressed("sprint") and sprint_gas > 0 and engine_force < max_engine_force_value:
		engine_force_value = max_engine_force_value
		sprint_gas -= delta * 10

		if sprint_gas < 0:
			sprint_gas = 0

		Events.emit_signal("update_sprint_bar", sprint_gas)
	else:
		engine_force_value = default_force_value

	var throttle = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	engine_force = clamp(lerp(engine_force, throttle * engine_force_value, delta * 10), -max_engine_force_value, max_engine_force_value)

	steer_target = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	steer_target *= steer_limit

	if steer_target < steer_angle:
		steer_angle -= steer_speed * delta
		if steer_target > steer_angle:
			steer_angle = steer_target
	elif steer_target > steer_angle:
		steer_angle += steer_speed * delta
		if steer_target < steer_angle:
			steer_angle = steer_target

	steering = steer_angle
	play_vehicle_engine_sounds()

	# exit vehicle
	if Input.is_action_just_pressed("jump") or Input.is_action_just_released("jump"):
		if is_instance_valid(player_factory) and inside_vehicle:
			inside_vehicle = false
			exit_vehicle()


func increase_sprint(value: float):
	sprint_gas += value

	if sprint_gas > 100:
		sprint_gas = 100

	Events.emit_signal("update_sprint_bar", sprint_gas)


func increase_jump(value: float):
	jump_gas += value

	if jump_gas > 100:
		jump_gas = 100

	Events.emit_signal("update_jump_bar", jump_gas)


func _on_Player_body_entered(body):
	grunts_sounds_player.stream = grunts_SFX[randi() % grunts_SFX.size()]
	grunts_sounds_player.play()

	for spark in crash_sparks:
		Utilities.start_particle_system(spark)

	if body is KinematicBody and body.get_child(0).has_method("apply_damage"):
		body.get_child(0).apply_damage(100, body.global_transform.basis.z, true)
		return

	# push rigidbodies
	if body is RigidBody:
		body.apply_central_impulse((body.global_transform.origin - global_transform.origin).normalized() * 3)


func play_vehicle_engine_sounds():
	if linear_velocity.length() > high_sfx_speed and vehicle_sounds_player.stream != high_speed_sfx:
		vehicle_sounds_player.stream = high_speed_sfx
		vehicle_sounds_player.play()
		return

	if (linear_velocity.length() > running_sfx_speed and linear_velocity.length() < 15)\
		and vehicle_sounds_player.stream != running_sfx:
		vehicle_sounds_player.stream = running_sfx
		vehicle_sounds_player.play()
		return

	if linear_velocity.length() < 5 and vehicle_sounds_player.stream != idle_sfx:
		vehicle_sounds_player.stream = idle_sfx
		vehicle_sounds_player.play()
		return


func exit_vehicle():
	GlobalSounds.play_global_sound(5)
	BackgroundLoader.fade_in_out()
	yield(get_tree().create_timer(0.5),"timeout")
	self.set_name("OldPlayer")
	player_factory.create_player(PlayerFactory.PlayerType.PLAYER, global_transform.origin + (Vector3.UP * (exit_vehicle_spawn_height + exit_player_spawn_height)), rotation)
	player_factory.create_enter_vehicle(vehicle_type, global_transform.origin + (Vector3.UP * exit_vehicle_spawn_height), rotation)
	queue_free()

