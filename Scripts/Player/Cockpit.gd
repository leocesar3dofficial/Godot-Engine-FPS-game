extends KinematicBody


export var rotation_speed: float = 2

#input variables
export(String) var forward_input = "move_forward"
export(String) var backward_input = "move_backward"
export(String) var left_input = "move_left"
export(String) var right_input = "move_right"
export(String) var up_input = "move_up"
export(String) var down_input = "move_down"
export(String) var sprint_input = "sprint"
export(String) var exit_input = "jump"

#fly variables
export(float) var max_fly_speed = 20.0
export(float) var max_fly_sprinting_speed = 40.0
var fly_speed = max_fly_speed
export(float) var fly_accel = 4.0

export(Resource) var exit_sfx
export(NodePath) var audio_player_path
var audio_player: AudioStreamPlayer3D

var velocity: Vector3 = Vector3()
var direction: Vector3 = Vector3()
var sprint_gas: float = 100
var sprinting: bool = false
var jump_gas: float = 100
var inside_cockpit: bool = false
onready var player_factory: PlayerFactory = get_node_or_null("/root/Level/PlayerFactory") as PlayerFactory


func _ready():
	audio_player = get_node(audio_player_path)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Events.emit_signal("update_sprint_bar", sprint_gas)
	Events.emit_signal("player_entered_scene") # tell Points of Interest that the Player is on the scene
	# prevents fast exiting of cockpit
	yield(get_tree().create_timer(3), "timeout")
	inside_cockpit = true


func _process(delta):
	var temp_quat = global_transform.basis.get_rotation_quat().slerp($Head/Camera.global_transform.basis.get_rotation_quat(), rotation_speed * delta)
	global_transform.basis = Basis(temp_quat)

	# level the cockpit to up vector
	var normal = Utilities.align_with_y(transform, Vector3.UP)
	transform = transform.interpolate_with(normal, delta * 0.5)

	# reset the direction of the player
	direction = Vector3()

	# get the rotation of the camera
	var aim: Basis = $Head/Camera.get_global_transform().basis

	# check input and change direction
	if Input.is_action_pressed(forward_input):
		direction -= aim.z
	if Input.is_action_pressed(backward_input):
		direction += aim.z
	if Input.is_action_pressed(left_input):
		direction -= aim.x
	if Input.is_action_pressed(right_input):
		direction += aim.x
	if Input.is_action_pressed(up_input):
		direction += global_transform.basis.y
	if Input.is_action_pressed(down_input):
		direction -= global_transform.basis.y

	direction = direction.normalized()

	# sprinting
	if Input.is_action_pressed(sprint_input) and sprint_gas > 0:
		sprinting = true
		fly_speed = max_fly_sprinting_speed
		sprint_gas -= delta * 10

		if sprint_gas < 0:
			sprint_gas = 0

		Events.emit_signal("update_sprint_bar", sprint_gas)
	else:
		sprinting = false
		fly_speed = max_fly_speed

	# where would the player go at max speed
	var target = direction * fly_speed

	# calculate a portion of the distance to go
	velocity = velocity.linear_interpolate(target, fly_accel * delta)

	# move
	velocity = move_and_slide(velocity, Vector3.UP, false, 1, 0.78, false)

	# exit fighter
	if Input.is_action_just_pressed(exit_input) or Input.is_action_just_released(exit_input):
		if is_instance_valid(player_factory) and inside_cockpit:
			var space: PhysicsDirectSpaceState = self.get_world().direct_space_state
			# collide with general layer
			var hit_down: Dictionary = space.intersect_ray(self.global_transform.origin, self.global_transform.origin - (Vector3.UP * 5), [self], self.collision_mask)
			var hit_up: Dictionary = space.intersect_ray(self.global_transform.origin, self.global_transform.origin + (Vector3.UP * 20), [self], self.collision_mask)

			if hit_down and not hit_up:
				inside_cockpit = false
				exit_fighter(hit_down)

	# push rigidbodies
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider is RigidBody:
			collision.collider.apply_central_impulse(-collision.normal * 3)


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


func exit_fighter(hit: Dictionary):
	GlobalSounds.play_global_sound(5)
	var player_rotation: Vector3 = rotation
	player_rotation.y = player_rotation.y + deg2rad(180)
	BackgroundLoader.fade_in_out()
	self.set_name("OldPlayer")
	yield(get_tree().create_timer(0.5), "timeout")
	player_factory.create_player(PlayerFactory.PlayerType.PLAYER, hit.position + (Vector3.UP * 3), player_rotation)
	player_factory.create_enter_vehicle(PlayerFactory.VehicleType.FIGHTER, global_transform.origin + (Vector3.UP * 8), rotation)
	queue_free()

