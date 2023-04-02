extends Spatial


export(String) var task_name = "ActivatePortal"
export(String) var condition_name = "ActivatePowerPlant1"
export(NodePath) var visibility_node_path
export(NodePath) var process_node_path
export(NodePath) var point_of_interest_node_path
export(NodePath) var audio_node_path
export var disabled_at_start: bool = true
onready var visibility_node = get_node_or_null(visibility_node_path)
onready var process_node = get_node_or_null(process_node_path)
onready var point_of_interest = get_node_or_null(point_of_interest_node_path)
onready var audio_node = get_node_or_null(audio_node_path)


func _ready():
	# warning-ignore:return_value_discarded
	Events.connect("update_task", self, "_on_update_task")

	if disabled_at_start:
		if is_instance_valid(visibility_node):
			visibility_node.visible = false

		if is_instance_valid(process_node):
			process_node.set_process(false)

		if is_instance_valid(audio_node):
			audio_node.stop()


func _on_update_task(_task_name: String, _condition_name: String, _condition_met: bool):
	if task_name == _task_name and condition_name == _condition_name:
		if is_instance_valid(visibility_node):
			visibility_node.visible = _condition_met

		if is_instance_valid(process_node):
			process_node.set_process(_condition_met)

		if is_instance_valid(point_of_interest):
			point_of_interest.remove_pointer()

		if is_instance_valid(audio_node):
			if _condition_met:
				audio_node.play()
			else:
				audio_node.stop()
