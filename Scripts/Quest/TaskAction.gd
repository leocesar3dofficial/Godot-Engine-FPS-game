extends Node


export var one_shot: bool = false
export var can_revert: bool = false
onready var task_node = get_parent().get_parent()
onready var task_name = task_node.name
var executed: bool = false


func execute():
	if one_shot and executed:
		return
	else:
		if not executed:
			executed = true

		Events.emit_signal("execute_action", task_name, name)


func revert():
	if not one_shot and executed:
		Events.emit_signal("revert_action", task_name, name)
