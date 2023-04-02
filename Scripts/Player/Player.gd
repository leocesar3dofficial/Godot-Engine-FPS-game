extends KinematicBody
class_name Player


#input variables
export(String) var forward_input = "move_forward"
export(String) var backward_input = "move_backward"
export(String) var left_input = "move_left"
export(String) var right_input = "move_right"
export(String) var up_input = "move_up"
export(String) var down_input = "move_down"
export(String) var sprint_input = "sprint"
export(String) var jump_input = "jump"
export(String) var crouch_input = "crouch"

#fly variables
export(float) var max_fly_speed = 20.0
export(float) var max_fly_sprinting_speed = 40.0
var fly_speed = max_fly_speed
export(float) var fly_accel = 4.0
export var flying: bool = false

#walk variables
export(float) var gravity = -30.0
export(float) var max_speed = 20.0
export(float) var max_running_speed = 40.0
export(float) var accel = 2.0
export(float) var deaccel = 6.0
var collision_shape: Shape
export var capsule_height: float = 1.6
var speed = max_speed
var grounded_time: float = 0.0

#jumping
export(float) var jump_height = 12.0
var air_time: float = 0
var can_double_jump: bool = false

#slope variables
export(float) var max_slope_angle = 60.0

#stair variables
export(float) var max_stair_slope = 20.0
export(float) var stair_jump_height = 8.0

export(NodePath) var audio_player_path
var audio_player: AudioStreamPlayer
export(Resource) var jump_sound
export(Array, Resource) var running_sounds
export(Resource) var falling_sound
onready var audio_player_sprint: AudioStreamPlayer = get_node("Sprinting")

enum GroundStates {
	GROUNDED,
	MIDAIR
}

var velocity: Vector3 = Vector3()
var direction: Vector3 = Vector3()
var sprint_gas: float = 100
var jump_gas: float = 100
var sprinting: bool = false
var floor_velocity: Vector3 = Vector3.ZERO
var floor_rotation: Vector3 = Vector3.ZERO
var crouched: bool = false
var crouched_height: float
var is_on_platform: bool = false
var current_ground_state: int = GroundStates.MIDAIR
var camera: Camera
var head: Spatial
var head_height: float
var ceiling: RayCast
var tail: RayCast
var stair_catcher: RayCast
onready var audio_player_fall: AudioStreamPlayer3D = $AudioStreamPlayer


func _ready():
	audio_player = get_node(audio_player_path)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Events.emit_signal("update_sprint_bar", sprint_gas)
	collision_shape = $CollisionShape.shape
	crouched_height = collision_shape.height / 3
	camera = $Head/Headbobber/Camera
	head = $Head
	head_height = capsule_height / 2
	ceiling = $Ceiling
	tail = $Tail
	stair_catcher = $StairCatcher
	Events.emit_signal("player_entered_scene") # tell Points of Interest that the Player is on the scene


func _process(delta):
	if flying:
		fly(delta)
	else:
		walk(delta)

	# push rigidbodies
	for index in get_slide_count():
		var collision = get_slide_collision(index)

		if collision.collider is RigidBody:
			collision.collider.apply_central_impulse(-collision.normal * 3)


func walk(delta):
	# reset the direction of the player
	direction = Vector3()
	var temp_velocity = velocity
	temp_velocity.y = 0

	# get the rotation of the camera
	var aim: Basis = camera.get_global_transform().basis
	# check input and change direction
	if Input.is_action_pressed(forward_input):
		direction -= aim.z
	if Input.is_action_pressed(backward_input):
		direction += aim.z
	if Input.is_action_pressed(left_input):
		direction -= aim.x
	if Input.is_action_pressed(right_input):
		direction += aim.x

	direction.y = 0
	direction = direction.normalized()

	if crouched:
		if collision_shape.get_height() > crouched_height:
			collision_shape.set_height(lerp(collision_shape.get_height(), crouched_height, deaccel * delta))
			head.set_translation(head.translation.linear_interpolate(Vector3.ZERO, deaccel * delta))
	else:
		if not ceiling.is_colliding() and collision_shape.get_height() < capsule_height:
			collision_shape.set_height(lerp(collision_shape.get_height(), capsule_height, deaccel * delta))
			head.set_translation(head.translation.linear_interpolate(Vector3(0, head_height, 0), deaccel * delta))

	match current_ground_state:
		GroundStates.GROUNDED:
			grounded_time += delta

			# play footsteps sound?
			if not crouched and not audio_player.playing and velocity.length() > 20:
				audio_player.stream = running_sounds[randi() % running_sounds.size()]
				audio_player.play()

			# crouching
			if Input.is_action_just_released(crouch_input):
				crouched = !crouched

			# jump
			if (Input.is_action_pressed(jump_input) or Input.is_action_just_released(jump_input)) and grounded_time > 0.1 and not ceiling.is_colliding():
				grounded_time = 0
				current_ground_state = GroundStates.MIDAIR
				can_double_jump = true
				crouched = false
				Events.emit_signal("camera_shaked", 0.2)

				if sprinting and jump_gas > 0:
					velocity.y = jump_height * 2
					jump_gas -= 5
					Events.emit_signal("camera_shaked", 0.2)

					if jump_gas < 0:
						jump_gas = 0

					Events.emit_signal("update_jump_bar", jump_gas)
				else:
					velocity.y = jump_height

				audio_player.stream = jump_sound
				audio_player.play()

			# aligns with rotating platform and kinematic bodies
			if tail.is_colliding():
				if tail.get_collider() is KinematicBody:
					is_on_platform = true # used by bobbing script (don't head bob if on platform), not ideal but works
					global_transform.basis = global_transform.basis.slerp(Utilities.align_with_y(tail.get_collider().global_transform, Vector3.UP).basis, delta * speed)
				else:
					is_on_platform = false

				# slide on slope?
#				var collision_normal = tail.get_collision_normal()
#				var floor_angle = rad2deg(acos(collision_normal.dot(Vector3.UP)))
#
#				if floor_angle > max_slope_angle:
#					velocity.y += gravity * delta
			else:
				current_ground_state = GroundStates.MIDAIR

		GroundStates.MIDAIR:
			air_time += delta
			velocity.y += gravity * delta
			crouched = false

			if can_double_jump and jump_gas > 0 and air_time > 0.15 and Input.is_action_just_released(jump_input):
				jump_gas -= 5

				if jump_gas < 0:
					jump_gas = 0

				Events.emit_signal("update_jump_bar", jump_gas)
				can_double_jump = false
				velocity.y = jump_height * 2
				audio_player.stream = jump_sound
				audio_player.play()

			if air_time > 2 and velocity.y < -30:
				if not audio_player_fall.is_playing():
					audio_player_fall.stream = falling_sound
					audio_player_fall.play()

			if air_time > 10 and velocity.y < -60:
				get_child(0).apply_damage(200, Vector3.UP)
				return

			if is_on_floor():
				if velocity.y < -60:
					get_child(0).apply_damage(10, Vector3.UP)

				air_time = 0

				if audio_player_fall.stream == falling_sound:
					audio_player_fall.stop()
				
				velocity += tail.get_collision_normal().inverse() * gravity / 3
				Events.emit_signal("camera_shaked", 0.2)
				current_ground_state = GroundStates.GROUNDED

	# calculate StairCatcher
	stair_catcher.translation.x = direction.x
	stair_catcher.translation.z = direction.z

	if (direction.length() > 0 and stair_catcher.is_colliding()):
		var stair_normal = stair_catcher.get_collision_normal()
		var stair_angle = rad2deg(acos(stair_normal.dot(Vector3.UP)))

		if stair_angle < max_stair_slope:
			velocity.y = stair_jump_height

	# sprinting
	if Input.is_action_pressed(sprint_input) and sprint_gas > 0 and not crouched:
		if not audio_player_sprint.is_playing():
			audio_player_sprint.play()

		sprinting = true
		speed = max_running_speed
		sprint_gas -= delta * 5

		if sprint_gas < 0:
			sprint_gas = 0

		Events.emit_signal("update_sprint_bar", sprint_gas)
	else:
		sprinting = false
		speed = max_speed

	# where would the player go at max speed
	var target = direction * speed
	var acceleration

	if direction.dot(temp_velocity) > 0:
		acceleration = accel
	else:
		acceleration = deaccel

	# calculate a portion of the distance to go
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta)
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z

	# move
	if current_ground_state == GroundStates.GROUNDED:
		velocity = move_and_slide_with_snap(velocity, Vector3.DOWN, Vector3.UP, true, 4, deg2rad(max_slope_angle), false)
	else:
		# on the air
		velocity = move_and_slide(velocity, Vector3.UP, true, 4, deg2rad(max_slope_angle), false)


func fly(delta):
	# reset the direction of the player
	direction = Vector3()

	# get the rotation of the camera
	var aim: Basis = camera.get_global_transform().basis

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
		direction += Vector3.UP
	if Input.is_action_pressed(down_input):
		direction += Vector3.DOWN

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
	velocity = move_and_slide(velocity, Vector3.UP, false, 4, 0.78, false)

	# jump
	if Input.is_action_pressed(jump_input) or Input.is_action_just_released(jump_input):
		velocity.y = jump_height


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
