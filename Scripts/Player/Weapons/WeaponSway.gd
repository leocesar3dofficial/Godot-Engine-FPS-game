extends Spatial


export var amount: float = 0.04
export var max_amount: float = 0.08
export var smooth_amount: float = 6
var initial_position: Vector3
var mouse_position: Vector2


func _ready():
	initial_position = translation


func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.relative
		return

	if event is InputEventJoypadMotion:
		if event.axis == 2:
			mouse_position = Vector2(event.axis_value, mouse_position.y)

		if event.axis == 3:
			mouse_position = Vector2(mouse_position.x, event.axis_value)


func _process(delta):
	var movement_x: float = -mouse_position.x * amount
	var movement_y: float = -mouse_position.y * amount
	movement_x = clamp(movement_x, -max_amount, max_amount)
	movement_y = clamp(movement_y, -max_amount, max_amount)
	var final_position: Vector3 = Vector3(movement_x, movement_y, movement_x)
	translation = translation.linear_interpolate(final_position + initial_position, smooth_amount * delta)
