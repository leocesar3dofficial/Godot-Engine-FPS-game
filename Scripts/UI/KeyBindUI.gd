extends Control

export var action: String = ""
func _ready():
	# warning-ignore:return_value_discarded
	get_child(1).connect("mouse_entered", self, "_on_mouse_entered_primary")
	# warning-ignore:return_value_discarded
	get_child(2).connect("mouse_entered", self, "_on_mouse_entered_secondary")
	update_buttons()


func update_buttons():
	var primary: String = InputMap.get_action_list(action)[0].as_text()
	var secondary: String = InputMap.get_action_list(action)[1].as_text()

	if "InputEventMouseButton : button_index=BUTTON_LEFT" in primary:
		primary = "Mouse Button Left"

	if "InputEventMouseButton : button_index=BUTTON_RIGHT" in primary:
		primary = "Mouse Button Right"

	if "InputEventMouseButton : button_index=BUTTON_WHEEL_DOWN" in primary:
		primary = "Mouse Wheel Down"

	if "InputEventMouseButton : button_index=BUTTON_WHEEL_UP" in primary:
		primary = "Mouse Wheel Up"

	if "InputEventMouseButton : button_index=BUTTON_MIDDLE" in primary:
		primary = "Mouse Wheel Middle"

	match secondary:
		"InputEventJoypadMotion : axis=1, axis_value=-1":
			secondary = "Left Thumbstick Up"
		"InputEventJoypadMotion : axis=1, axis_value=1":
			secondary = "Left Thumbstick Down"
		"InputEventJoypadMotion : axis=0, axis_value=1":
			secondary = "Left Thumbstick Right"
		"InputEventJoypadMotion : axis=0, axis_value=-1":
			secondary = "Left Thumbstick Left"
		"InputEventJoypadMotion : axis=3, axis_value=-1":
			secondary = "Right Thumbstick Up"
		"InputEventJoypadMotion : axis=3, axis_value=1":
			secondary = "Right Thumbstick Down"
		"InputEventJoypadMotion : axis=2, axis_value=1":
			secondary = "Right Thumbstick Right"
		"InputEventJoypadMotion : axis=2, axis_value=-1":
			secondary = "Right Thumbstick Left"
		"InputEventJoypadButton : button_index=5, pressed=false, pressure=0":
			secondary = "Right Bumper"
		"InputEventJoypadButton : button_index=4, pressed=false, pressure=0":
			secondary = "Left Bumper"
		"InputEventJoypadButton : button_index=9, pressed=false, pressure=0":
			secondary = "Right Thumbstick Button"
		"InputEventJoypadButton : button_index=8, pressed=false, pressure=0":
			secondary = "Left Thumbstick Button"
		"InputEventJoypadButton : button_index=0, pressed=false, pressure=0":
			secondary = "Cross, Xbox A, Nintendo B"
		"InputEventJoypadButton : button_index=1, pressed=false, pressure=0":
			secondary = "Circle, Xbox B, Nintendo A"
		"InputEventJoypadButton : button_index=7, pressed=false, pressure=0":
			secondary = "Right Trigger"
		"InputEventJoypadButton : button_index=6, pressed=false, pressure=0":
			secondary = "Left Trigger"
		"InputEventJoypadButton : button_index=3, pressed=false, pressure=0":
			secondary = "Triangle, Xbox Y, Nintendo X"
		"InputEventJoypadButton : button_index=2, pressed=false, pressure=0":
			secondary = "Square, Xbox X, Nintendo Y"

	get_child(1).text = primary
	get_child(2).text = secondary


func _on_mouse_entered_primary():
	get_child(1).grab_focus()


func _on_mouse_entered_secondary():
	get_child(2).grab_focus()
