extends Button


export(NodePath) var labels_parent_path
export var characters_per_second: float = 60
var labels: Array
var current_index: int = 0
var can_animate_text: bool = true
var labels_length: Array


func _ready():
	# save game progress the time player enter cutscene
	var current_level: int = BackgroundLoader.levels.find(get_node("/root/Level/").filename)

	if current_level != 0: # save if not the first cutscene
		SaveLoadGame.save_game(current_level) # save this cutscene as continue level

	grab_focus()
	connect("pressed", self, "_on_Button_pressed") # warning-ignore:return_value_discarded
	connect("mouse_entered", self, "_on_Button_mouse_entered") # warning-ignore:return_value_discarded
	labels = get_node(labels_parent_path).get_children()

	for l in labels:
		labels_length.append(l.text.length())
		l.visible = false
		l.percent_visible = 0

	labels[0].visible = true

func _process(delta):
	if labels[current_index].percent_visible < 1:
		labels[current_index].percent_visible += delta / (float(labels_length[current_index]) / characters_per_second)
	else:
		set_process(false)


func _on_Button_pressed():
	set_process(true)
	GlobalSounds.play_global_sound(0)
	labels[current_index].percent_visible = 1
	current_index += 1
	labels[current_index].visible = true

	if current_index == labels.size() - 1:
		disabled = true
		visible = false
		get_parent().get_node("ButtonSkip").grab_focus()


func _on_Button_mouse_entered():
	grab_focus()
