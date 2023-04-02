extends Spatial


export(String) var sprint_input = "sprint"
export(NodePath) var player_path
var player: Player
export var bobbing_speed: float = 18
export var bobbing_amount: float = 0.046
export var midpoint: float = 0
export var run_multiplier: float = 1.25
var timer: float = 0
var waveslice: float = 0
var translate_change: float
var total_axes: float
var accel: float = 6
var horizontal: float = 0
var vertical: float = 0


func _ready():
	Events.connect("headbobbing", self, "_on_headbobbing") # warning-ignore:return_value_discarded
	player = get_node(player_path)
	set_process(Settings.headbobbing);


func _process(delta):
	if player.current_ground_state == player.GroundStates.GROUNDED:
		horizontal = lerp(horizontal, Input.get_action_strength("move_left") + Input.get_action_strength("move_right"), accel * delta)
		vertical = lerp(vertical, Input.get_action_strength("move_forward") + Input.get_action_strength("move_backward"), accel * delta)

		if abs(horizontal) == 0 and abs(vertical) == 0:
			timer = 0
		else:
			waveslice = sin(timer)
			var multiplier: float = 1

			if Input.is_action_pressed(sprint_input):
				multiplier = run_multiplier

			timer = timer + bobbing_speed * delta * multiplier

			if timer > (PI * 2):
				timer = timer - (PI * 2)

		if waveslice != 0:
			translate_change = waveslice * bobbing_amount
			total_axes = abs(horizontal) + abs(vertical)
			total_axes = clamp(total_axes, 0, 1)
			translate_change = total_axes * translate_change
			translation = Vector3(translation.x, midpoint + translate_change, translation.z)
		else:
			translation = Vector3(translation.x, midpoint, translation.z)


# warning-ignore:unused_argument
func _on_headbobbing(on: bool):
	set_process(on)
