extends State


export var move_speed: float = 4
export var rotation_speed: float = 4
export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
var manager: StateManager
var velocity: Vector3 = Vector3()


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)


func _tick(delta: float):
	var target_direction: Vector3 = manager.target_last_position - top_node.global_transform.origin
	velocity = target_direction.normalized() * move_speed
	velocity = Utilities.move_towards(top_node, manager.target_last_position, velocity, rotation_speed, delta)


func _exit():
	manager.velocity = velocity
