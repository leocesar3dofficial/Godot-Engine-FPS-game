extends Node
class_name Transition


export(NodePath) var condition_path
var condition: Condition
export(NodePath) var target_state_path
var target_state: State


func _ready():
	condition = get_node(condition_path)
	target_state = get_node(target_state_path)
