extends Node
class_name State


# transitions must be chilren of each state
var transitions = []


func _ready():
	for node in get_children():
		transitions.append(node)


func _enter():
	pass


# warning-ignore:unused_argument
func _tick(delta: float):
	pass


# warning-ignore:unused_argument
func _tick_physics(delta: float):
	pass


func _exit():
	pass
