extends State


export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
var manager: StateManager


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)


func _enter():
	manager.target = null
	manager.target_last_position += Vector3(rand_range(-10, 10), 0, rand_range(-10, 10))


func _exit():
	# choose a random place to go while has no target
	manager.target_last_position = Utilities.random_direction(top_node.global_transform)
