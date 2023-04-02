extends State


export var move_speed: float = 4
export var rotation_speed: float = 4
export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
export var dont_come_close: float = 5
var manager: StateManager
var velocity: Vector3 = Vector3()


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)


func _tick(delta: float):
	if is_instance_valid(manager.target):
		manager.target_last_position = manager.target.global_transform.origin

		var distance: float = top_node.global_transform.origin.distance_to(manager.target.global_transform.origin)

		if distance > dont_come_close:
			velocity = -top_node.global_transform.basis.z * move_speed
			velocity = Utilities.move_towards(top_node, manager.target_last_position, velocity, rotation_speed, delta)


func _exit():
	manager.velocity = velocity
