extends Area


export var on: bool = false
export(String) var task_name
export(String) var action_name


func _ready():
	connect("body_entered", self, "_on_Area_body_entered") # warning-ignore:return_value_discarded
	Events.connect("execute_action", self, "_on_execute_action") # warning-ignore:return_value_discarded
	Events.connect("revert_action", self, "_on_revert_action") # warning-ignore:return_value_discarded
	Events.connect("player_entered_scene", self, "_on_player_entered_scene") # warning-ignore:return_value_discarded

	if on:
		visible = true
		set_deferred("monitoring", true)
	else:
		visible = false
		set_deferred("monitoring", false)


func _on_Area_body_entered(body):
	if body.name == "Player":
		set_deferred("monitoring", false)
		BackgroundLoader.play_badge(0, 2) # play win badge
		GlobalSounds.play_global_sound(2)
		BackgroundLoader.load_scene(BackgroundLoader.levels[BackgroundLoader.levels.find(get_node("/root/Level/").filename) + 1], 0.5)


func _on_execute_action(_task_name, _action_name):
	if task_name == _task_name and action_name == _action_name:
		on = true
		Events.emit_signal("add_pointer", self, UnitsManager.UnitsType.POINT)
		visible = true
		monitoring = true


func _on_revert_action(_task_name, _action_name):
	if task_name == _task_name and action_name == _action_name:
		on = false
		Events.emit_signal("remove_pointer", self)
		visible = false
		monitoring = false

func _on_player_entered_scene():
	if on:
		Events.emit_signal("add_pointer", self, UnitsManager.UnitsType.POINT)
	else:
		Events.emit_signal("remove_pointer", self)
