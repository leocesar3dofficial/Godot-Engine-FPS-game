extends Control


enum input_actions {move_forward, move_backward, move_right, move_left, move_up, move_down,
					sprint, jump, crouch, fire, fire2, switch_weapon, previous_weapon}

var can_change_key: bool = false
var action_string: String
var primary: bool = false
var current_event: InputEvent
var thumbstick_items: Array = ["Left Thumbstick Up",
								"Left Thumbstick Down",
								"Left Thumbstick Left",
								"Left Thumbstick Right",
								"Right Thumbstick Up",
								"Right Thumbstick Down",
								"Right Thumbstick Left",
								"Right Thumbstick Right"]
var joy_button_items: Array = ["Right Bumper",
								"Left Bumper",
								"Right Trigger",
								"Left Trigger",
								"Right Thumbstick Button",
								"Left Thumbstick Button",
								"Circle, Xbox B, Nintendo A",
								"Cross, Xbox A, Nintendo B",
								"Triangle, Xbox Y, Nintendo X",
								"Square, Xbox X, Nintendo Y"]


func _ready():
	# assign items to option lists
	for item in thumbstick_items:
		$ColorRect/VBoxContainer/MoveForward/MoveForwardSecondary.add_item(item)
		$ColorRect/VBoxContainer/MoveBackward/MoveBackwardSecondary.add_item(item)
		$ColorRect/VBoxContainer/MoveLeft/MoveLeftSecondary.add_item(item)
		$ColorRect/VBoxContainer/MoveRight/MoveRightSecondary.add_item(item)

	for item in joy_button_items:
		$ColorRect/VBoxContainer/MoveUp/MoveUpSecondary.add_item(item)
		$ColorRect/VBoxContainer/MoveDown/MoveDownSecondary.add_item(item)
		$ColorRect/VBoxContainer/Sprint/SprintSecondary.add_item(item)
		$ColorRect/VBoxContainer/Jump/JumpSecondary.add_item(item)
		$ColorRect/VBoxContainer/Crouch/CrouchSecondary.add_item(item)
		$ColorRect/VBoxContainer/Fire/FireSecondary.add_item(item)
		$ColorRect/VBoxContainer/Fire2/Fire2Secondary.add_item(item)
		$ColorRect/VBoxContainer/WeaponSwitch/WeaponSwitchSecondary.add_item(item)
		$ColorRect/VBoxContainer/WeaponPrevious/WeaponPreviousSecondary.add_item(item)

	update_all_buttons()

	# set selected drop down list as in Input Map
	$ColorRect/VBoxContainer/MoveForward/MoveForwardSecondary.selected = input_map_joy_stick_to_index("move_forward")
	$ColorRect/VBoxContainer/MoveBackward/MoveBackwardSecondary.selected = input_map_joy_stick_to_index("move_backward")
	$ColorRect/VBoxContainer/MoveLeft/MoveLeftSecondary.selected = input_map_joy_stick_to_index("move_left")
	$ColorRect/VBoxContainer/MoveRight/MoveRightSecondary.selected = input_map_joy_stick_to_index("move_right")
	$ColorRect/VBoxContainer/MoveUp/MoveUpSecondary.selected = input_map_joy_button_to_index("move_up")
	$ColorRect/VBoxContainer/MoveDown/MoveDownSecondary.selected = input_map_joy_button_to_index("move_down")
	$ColorRect/VBoxContainer/Sprint/SprintSecondary.selected = input_map_joy_button_to_index("sprint")
	$ColorRect/VBoxContainer/Jump/JumpSecondary.selected = input_map_joy_button_to_index("jump")
	$ColorRect/VBoxContainer/Crouch/CrouchSecondary.selected = input_map_joy_button_to_index("crouch")
	$ColorRect/VBoxContainer/Fire/FireSecondary.selected = input_map_joy_button_to_index("fire")
	$ColorRect/VBoxContainer/Fire2/Fire2Secondary.selected = input_map_joy_button_to_index("fire2")
	$ColorRect/VBoxContainer/WeaponSwitch/WeaponSwitchSecondary.selected = input_map_joy_button_to_index("switch_weapon")
	$ColorRect/VBoxContainer/WeaponPrevious/WeaponPreviousSecondary.selected = input_map_joy_button_to_index("previous_weapon")


func _input(event):

	if can_change_key:
		if primary:
			if event is InputEventKey or event is InputEventMouseButton:
				can_change_key = false
				current_event = event
				GlobalSounds.play_global_sound(1)
				$ColorRect/ConfirmationDialog.dialog_text = event.as_text()

				if "InputEventMouseButton : button_index=BUTTON_LEFT" in event.as_text():
					$ColorRect/ConfirmationDialog.dialog_text = "Mouse Button Left"

				if "InputEventMouseButton : button_index=BUTTON_RIGHT" in event.as_text():
					$ColorRect/ConfirmationDialog.dialog_text = "Mouse Button Right"

				if "InputEventMouseButton : button_index=BUTTON_WHEEL_DOWN" in event.as_text():
					$ColorRect/ConfirmationDialog.dialog_text = "Mouse Wheel Down"

				if "InputEventMouseButton : button_index=BUTTON_WHEEL_UP" in event.as_text():
					$ColorRect/ConfirmationDialog.dialog_text = "Mouse Wheel Up"

				if "InputEventMouseButton : button_index=BUTTON_MIDDLE" in event.as_text():
					$ColorRect/ConfirmationDialog.dialog_text = "Mouse Wheel Middle"


func is_key_used(event: InputEvent) -> bool:
	for i in input_actions:
		var events = InputMap.get_action_list(i)

		for e in events:
			if e.as_text().substr(0, 54) == event.as_text().substr(0, 54):
				return true

	return false


func change_key(new_key: InputEvent):
	if not InputMap.get_action_list(action_string).empty():
		if is_key_used(new_key):
			$ColorRect/AcceptDialog.popup()

		if primary:
			var secondary: InputEvent = InputMap.get_action_list(action_string)[1]
			InputMap.action_erase_events(action_string)
#			InputMap.action_erase_event(action_string, InputMap.get_action_list(action_string)[0])
#			InputMap.action_erase_event(action_string, secondary)
			InputMap.action_add_event(action_string, new_key)
			InputMap.action_add_event(action_string, secondary)
		else:
			InputMap.action_erase_event(action_string, InputMap.get_action_list(action_string)[1])
			InputMap.action_add_event(action_string, new_key)

		update_all_buttons()


func update_all_buttons():
	var children: Array = $ColorRect/VBoxContainer.get_children()

	for child in children:
		if child.has_method("update_buttons"):
			child.update_buttons()


func change_button_key(action: String, _primary: bool):
	action_string = action
	primary = _primary
	can_change_key = true
	$ColorRect/ConfirmationDialog.popup()


func input_map_joy_stick_to_index(action: String):
	var event: String = InputMap.get_action_list(action)[1].as_text()

	match event:
		"InputEventJoypadMotion : axis=1, axis_value=-1":
			return 0
		"InputEventJoypadMotion : axis=1, axis_value=1":
			return 1
		"InputEventJoypadMotion : axis=0, axis_value=-1":
			return 2
		"InputEventJoypadMotion : axis=0, axis_value=1":
			return 3
		"InputEventJoypadMotion : axis=3, axis_value=-1":
			return 4
		"InputEventJoypadMotion : axis=3, axis_value=1":
			return 5
		"InputEventJoypadMotion : axis=2, axis_value=-1":
			return 6
		"InputEventJoypadMotion : axis=2, axis_value=1":
			return 7


func input_map_joy_button_to_index(action: String):
	var event: String = InputMap.get_action_list(action)[1].as_text()

	match event:
		"InputEventJoypadButton : button_index=5, pressed=false, pressure=0":
			return 0
		"InputEventJoypadButton : button_index=4, pressed=false, pressure=0":
			return 1
		"InputEventJoypadButton : button_index=7, pressed=false, pressure=0":
			return 2
		"InputEventJoypadButton : button_index=6, pressed=false, pressure=0":
			return 3
		"InputEventJoypadButton : button_index=9, pressed=false, pressure=0":
			return 4
		"InputEventJoypadButton : button_index=8, pressed=false, pressure=0":
			return 5
		"InputEventJoypadButton : button_index=1, pressed=false, pressure=0":
			return 6
		"InputEventJoypadButton : button_index=0, pressed=false, pressure=0":
			return 7
		"InputEventJoypadButton : button_index=3, pressed=false, pressure=0":
			return 8
		"InputEventJoypadButton : button_index=2, pressed=false, pressure=0":
			return 9


func joy_thumb_option_list_to_event(index: int):
	var joy_event: InputEventJoypadMotion = InputEventJoypadMotion.new()

	match index:
		0: # Left Thumbstick Up
			joy_event.axis = 1
			joy_event.axis_value = -1
		1: # Left Thumbstick Down
			joy_event.axis = 1
			joy_event.axis_value = 1
		2: # Left Thumbstick Left
			joy_event.axis = 0
			joy_event.axis_value = -1
		3: # Right Thumbstick Up
			joy_event.axis = 0
			joy_event.axis_value = 1
		4: # Left Thumbstick Up
			joy_event.axis = 3
			joy_event.axis_value = -1
		5: # Right Thumbstick Down
			joy_event.axis = 3
			joy_event.axis_value = 1
		6: # Right Thumbstick Left
			joy_event.axis = 2
			joy_event.axis_value = -1
		7: # Right Thumbstick Right
			joy_event.axis = 2
			joy_event.axis_value = 1

	return joy_event


func joy_button_option_list_to_event(index: int):
	var joy_event: InputEventJoypadButton = InputEventJoypadButton.new()

	match index:
		0: # Right Bumper
			joy_event.button_index = 5
		1: # Left Bumper
			joy_event.button_index = 4
		2: # Right Trigger
			joy_event.button_index = 7
		3: # Left Trigger
			joy_event.button_index = 6
		4: # Right Thumbstick pressed
			joy_event.button_index = 9
		5: # Left Thumbstick pressed
			joy_event.button_index = 8
		6: # Circle, Xbox B, Nintendo A
			joy_event.button_index = 1
		7: # Cross, Xbox A, Nintendo B
			joy_event.button_index = 0
		8: # Triangle, Xbox Y, Nintendo X
			joy_event.button_index = 3
		9: # Square, Xbox X, Nintendo Y
			joy_event.button_index = 2

	return joy_event


func change_secondary_thumb_list(action: String, index: int):
	action_string = action
	primary = false
	change_key(joy_thumb_option_list_to_event(index))


func change_secondary_button_list(action: String, index: int):
	action_string = action
	primary = false
	change_key(joy_button_option_list_to_event(index))


func _on_ConfirmationDialog_confirmed():
	if current_event != null:
		change_key(current_event)


func _on_ConfirmationDialog_popup_hide():
	GlobalSounds.play_global_sound(1)
	$ColorRect/ConfirmationDialog.dialog_text = "None"


func _on_MoveForwardPrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("move_forward", true)


func _on_MoveBackwardPrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("move_backward", true)


func _on_MoveRightPrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("move_right", true)


func _on_MoveLeftPrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("move_left", true)


func _on_MoveUpPrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("move_up", true)


func _on_MoveDownPrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("move_down", true)


func _on_SprintPrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("sprint", true)


func _on_JumpPrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("jump", true)


func _on_CrouchPrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("crouch", true)


func _on_FirePrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("fire", true)


func _on_Fire2Primary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("fire2", true)


func _on_WeaponSwitchPrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("switch_weapon", true)


func _on_WeaponPreviousPrimary_pressed():
	GlobalSounds.play_global_sound(0)
	change_button_key("previous_weapon", true)


func _on_MoveForwardSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_thumb_list("move_forward", index)


func _on_MoveBackwardSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_thumb_list("move_backward", index)


func _on_MoveLeftSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_thumb_list("move_left", index)


func _on_MoveRightSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_thumb_list("move_right", index)


func _on_MoveUpSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_button_list("move_up", index)


func _on_MoveDownSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_button_list("move_down", index)


func _on_SprintSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_button_list("sprint", index)


func _on_JumpSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_button_list("jump", index)


func _on_CrouchSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_button_list("crouch", index)


func _on_FireSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_button_list("fire", index)


func _on_Fire2Secondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_button_list("fire2", index)


func _on_WeaponSwitchSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_button_list("switch_weapon", index)


func _on_WeaponPreviousSecondary_item_selected(index):
	GlobalSounds.play_global_sound(1)
	change_secondary_button_list("previous_weapon", index)


func _on_ButtonReset_pressed():
	release_focus()
	GlobalSounds.play_global_sound(0)
	reset_input_map()


func reset_input_map():
	# Reset to default keybindings
	InputMap.load_from_globals()
	update_all_buttons()
	GlobalSounds.play_global_sound(0)
	$ColorRect/AcceptDialogReset.popup()


func _on_ButtonApply_pressed():
	GlobalSounds.play_global_sound(1)
	Settings.save_keybindings()


func _on_ButtonApply_mouse_entered():
	$ColorRect/VBoxContainer/Buttons/ButtonApply.grab_focus()


func _on_ButtonReset_mouse_entered():
	$ColorRect/VBoxContainer/Buttons/ButtonReset.grab_focus()
