extends Button


export var play_badge: bool = false
export var badge_type_and_sound: Vector2
export var immediate_loading: bool = false
export(String, FILE) var scene_path
var next_level_index: int


func _ready():
	connect("pressed", self, "_on_Button_pressed") # warning-ignore:return_value_discarded
	connect("mouse_entered", self, "_on_Button_mouse_entered") # warning-ignore:return_value_discarded
	next_level_index = BackgroundLoader.levels.find(get_owner().filename) + 1 # find the current level path index and add 1 == next level index

	if immediate_loading:
		disabled = true
		visible = false
		Events.connect("skip_button_visible", self, "_on_skip_button_visible") # warning-ignore:return_value_discarded
		Events.connect("ready_for_loading", self, "_on_ready_for_loading") # warning-ignore:return_value_discarded


func _on_Button_pressed():
	# turn off the button when pressed
	disabled = true
	visible = false
	GlobalSounds.play_global_sound(0)

	if scene_path:
		BackgroundLoader.load_scene(scene_path)
		return

	if immediate_loading:
		BackgroundLoader.Wait_for_loading_button()
	else:
		BackgroundLoader.load_scene(BackgroundLoader.levels[next_level_index], 0.5)

	if play_badge:
		BackgroundLoader.play_badge(int(badge_type_and_sound.x), int(badge_type_and_sound.y))


func _on_Button_mouse_entered():
	grab_focus()


func _on_skip_button_visible():
	disabled = false
	visible = true

	if get_parent().get_node("ButtonNext").visible == false:
		grab_focus()


func _on_ready_for_loading(): # emitted by BackgroundLoader when ready to load any scene
	BackgroundLoader.load_scene(BackgroundLoader.levels[next_level_index], 0.5, true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # keep mouse cursor visible in cutscenes
