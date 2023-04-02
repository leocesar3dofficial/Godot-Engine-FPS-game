extends Button


export var unpause_game: bool = true
export(NodePath) var node_to_hide_path
export(NodePath) var nodo_to_show_path
onready var node_to_hide = get_node(node_to_hide_path)
onready var node_to_show = get_node_or_null(nodo_to_show_path)


func _ready():
	grab_focus()
	# warning-ignore:return_value_discarded
	connect("pressed", self, "_on_Button_pressed")
	# warning-ignore:return_value_discarded
	connect("mouse_entered", self, "_on_Button_mouse_entered")


func _on_Button_pressed():
	release_focus()
	GlobalSounds.play_global_sound(0)
	node_to_hide.set_visible(false)

	if is_instance_valid(node_to_show):
		node_to_show.set_visible(true)

	if unpause_game:
		PauseMenu.pause_game(false)
		PauseMenu._on_ButtonResume_pressed()


func _on_Button_mouse_entered():
	grab_focus()
