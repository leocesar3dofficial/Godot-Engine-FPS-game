extends State


export var rotation_speed: float = 2
export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
var manager: StateManager


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)


func _enter():
	manager.target = null


func _tick(delta: float):
	Utilities.rotate_towards(top_node, manager.target_last_position, rotation_speed, delta)


func _exit():
	# choose a random place to go while has no target
	manager.target_last_position = Utilities.random_direction(top_node.global_transform, true)
