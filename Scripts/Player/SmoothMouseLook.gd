extends Camera


# User settings:
# General settings
export var enabled: bool = true setget set_enabled
export(int, "Visible", "Hidden", "Captured", "Confined") var mouse_mode: int = 2

# Mouslook settings
export var mouselook: bool = true
export (float, 0.0, 1.0) var sensitivity: float = 0.5
export (float, 0.0, 0.999, 0.001) var smoothness: float = 0.6 setget set_smoothness
export (int, 0, 360) var yaw_limit: int = 360
export (int, 0, 360) var pitch_limit: int = 85

# Intern variables.
var joy_horizontal_axis: int = 2
var joy_vertical_axis: int = 3
var joy_stick_dead_zone: float = 0.2
var _mouse_position: Vector2 = Vector2()
var _yaw: float = 0.0
var _pitch: float = 0.0
var _total_yaw: float = 0.0
var _total_pitch: float = 0.0
var speed: float = 1000.0
var invert_y: float = 1.0


func _ready():
	far = Settings.dist_cull
	fov = Settings.current_FOV
	sensitivity = Settings.look_sensitivity
	joy_horizontal_axis = Settings.joy_horizontal_axis
	joy_vertical_axis = Settings.joy_vertical_axis
	invert_y = Settings.invert_y
	# warning-ignore:return_value_discarded
	Events.connect("update_look_sensitivity", self, "_on_update_look_sensitivity")
	# warning-ignore:return_value_discarded
	Events.connect("change_FOV", self, "_on_change_FOV")
	# warning-ignore:return_value_discarded
	Events.connect("invert_y", self, "_on_invert_y")
	set_enabled(enabled)


func _input(event):
	if mouselook:
		# get mouse motion input
		if event is InputEventMouseMotion:
			_mouse_position = event.relative

	# change current camera Field of View (from 70 to 100)
	if Input.is_key_pressed(KEY_KP_SUBTRACT):
		if fov >= 80:
			fov -= 10
			Settings.current_FOV = fov
			return

	if Input.is_key_pressed(KEY_KP_ADD):
		if fov <= 90:
			fov += 10
			Settings.current_FOV = fov
			return


# warning-ignore:unused_argument
func _process(delta):
	if mouselook:
		_update_mouselook()
		_mouse_position = Vector2(Input.get_joy_axis(0, joy_horizontal_axis), Input.get_joy_axis(0, joy_vertical_axis))

		if _mouse_position.length() > joy_stick_dead_zone:
			#sensitivity dumpened by 30% on the joypad!
			_mouse_position *= speed * (sensitivity * 0.7) * delta * 1 / Engine.time_scale
		else:
			_mouse_position = Vector2.ZERO


func _update_mouselook():
	_mouse_position *= sensitivity
	_yaw = _yaw * smoothness + _mouse_position.x * (1.0 - smoothness)
	_pitch = (_pitch * smoothness + _mouse_position.y * (1.0 - smoothness)) * invert_y
	_mouse_position = Vector2()

	if yaw_limit < 360:
		_yaw = clamp(_yaw, -yaw_limit - _total_yaw, yaw_limit - _total_yaw)
	if pitch_limit < 360:
		_pitch = clamp(_pitch, -pitch_limit - _total_pitch, pitch_limit - _total_pitch)

	_total_yaw += _yaw
	_total_pitch += _pitch

	rotate_y(deg2rad(-_yaw))
	rotate_object_local(Vector3.RIGHT, deg2rad(-_pitch))


func set_enabled(value):
	enabled = value

	if enabled:
		Input.set_mouse_mode(mouse_mode)
		set_process(true)
		set_process_input(true)
	else:
		rotation = Vector3.ZERO
		set_process(false)
		set_process_input(false)


func set_smoothness(value):
	smoothness = clamp(value, 0.001, 0.999)


func _on_update_look_sensitivity():
	sensitivity = Settings.look_sensitivity


func _on_change_FOV():
	fov = Settings.current_FOV


func _on_invert_y():
	invert_y = Settings.invert_y
