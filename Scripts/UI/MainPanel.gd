extends Node


export(NodePath) var continue_button_path
export(String, FILE, "*.tscn") var credits_scene
onready var continue_button: Button = get_node(continue_button_path)


func _ready():
	continue_button.set_disabled(!SaveLoadGame.save_game_file_exists())
	continue_button.set_focus_mode(Control.FOCUS_ALL)

	if not continue_button.is_disabled():
		SaveLoadGame.load_game()
		continue_button.grab_focus()
	else:
		$VBoxContainer/NewGame.grab_focus()

	yield(get_tree().create_timer(1), "timeout")
	get_tree().get_root().set_disable_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_Continue_pressed():
	if not continue_button.disabled:
		GlobalSounds.play_global_sound(0)
		BackgroundLoader.load_scene(BackgroundLoader.levels[SaveLoadGame.checkpoint_level]) # load previous saved level cutscene
		continue_button.set_disabled(true)

func _on_NewGame_pressed():
	GlobalSounds.play_global_sound(0)
	SaveLoadGame.delete_game_save_file()
	BackgroundLoader.load_scene(BackgroundLoader.levels[0])


func _on_ButtonSettings_pressed():
	PauseMenu._on_ButtonSettings_pressed()


func _on_ButtonBindings_pressed():
	PauseMenu._on_ButtonKeyBindings_pressed()


func _on_ButtonCredits_pressed():
	GlobalSounds.play_global_sound(0)
	BackgroundLoader.load_scene(credits_scene)


func _on_ButtonExit_pressed():
	get_tree().quit()


func _on_NewGame_mouse_entered():
	$VBoxContainer/NewGame.grab_focus()


func _on_ButtonSettings_mouse_entered():
	$VBoxContainer/Settings.grab_focus()


func _on_ButtonBindings_mouse_entered():
	$VBoxContainer/Bindings.grab_focus()


func _on_ButtonCredits_mouse_entered():
	$VBoxContainer/Credits.grab_focus()


func _on_ButtonExit_mouse_entered():
	$VBoxContainer/Exit.grab_focus()


func _on_Continue_mouse_entered():
	if not continue_button.disabled:
		continue_button.grab_focus()
