extends Popup


var current_scene: Node
var can_pause: bool = false
export(String, FILE) var main_menu_path


func _ready():
	$MouseMovementJoypad.can_use = false


func pause_game(p: bool):
	get_tree().paused = p

	if get_tree().is_paused():
		raise() # show on top
		show()
		$MouseMovementJoypad.can_use = true
	else:
		hide()
		$MouseMovementJoypad.can_use = false
		$Settings.set_visible(false)
		$KeyBindings.set_visible(false)


# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_released("pause"):
		if can_pause:
			$ColorRect/VBoxContainer/ButtonResume.grab_focus()
			current_scene = get_tree().get_current_scene()

			if current_scene.name == "Level":
				GlobalSounds.play_global_sound(1)

				if get_tree().is_paused():
					pause_game(false)
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				else:
					pause_game(true)
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_ButtonResume_pressed():
	current_scene = get_tree().get_current_scene()
	GlobalSounds.play_global_sound(1)

	if current_scene.name == "Level":
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	pause_game(false)


func _on_ButtonMainMenu_pressed():
	GlobalSounds.play_global_sound(0)
	Jukebox.crossfade_music(false)
	pause_game(false)
	BackgroundLoader.load_scene(main_menu_path)


func _on_ButtonExit_pressed():
	get_tree().quit()


func _on_ButtonResume_mouse_entered():
	$ColorRect/VBoxContainer/ButtonResume.grab_focus()


func _on_ButtonMainMenu_mouse_entered():
	$ColorRect/VBoxContainer/ButtonMainMenu.grab_focus()


func _on_ButtonExit_mouse_entered():
	$ColorRect/VBoxContainer/ButtonExit.grab_focus()


func _on_ButtonSettings_pressed():
	GlobalSounds.play_global_sound(0)
	pause_game(true)
	$Settings.set_visible(true)


func _on_ButtonKeyBindings_pressed():
	GlobalSounds.play_global_sound(0)
	pause_game(true)
	$KeyBindings.set_visible(true)


func _on_ButtonSettings_mouse_entered():
	$ColorRect/VBoxContainer/ButtonSettings.grab_focus()


func _on_ButtonKeyBindings_mouse_entered():
	$ColorRect/VBoxContainer/ButtonKeyBindings.grab_focus()


func _on_ButtonRestartLevel_pressed():
	GlobalSounds.play_global_sound(0)
	Jukebox.crossfade_music(false)
	BackgroundLoader.fade_in_out()
	yield(get_tree().create_timer(0.5) , "timeout")
	pause_game(false)
	get_tree().reload_current_scene() # warning-ignore:return_value_discarded


func _on_ButtonRestartLevel_mouse_entered():
	$ColorRect/VBoxContainer/ButtonRestartLevel.grab_focus()
