extends Node


var condition_met: bool = false
onready var task_node = get_parent().get_parent()
onready var task_name = task_node.name
onready var condition_name = self.name


func _ready():
	# warning-ignore:return_value_discarded
	Events.connect("update_task", self, "_on_update_task")


func _on_update_task(_task_name: String, _condition_name: String, _condition_met: bool):
	if task_name == _task_name and condition_name == _condition_name:
		condition_met = _condition_met
		task_node.check_task_completion(task_name)
