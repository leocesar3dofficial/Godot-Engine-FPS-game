extends State


export var move_speed: float = 4
export var rotation_speed: float = 4
export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
var manager: StateManager
export var dont_come_close: float = 4
var velocity: Vector3 = Vector3()
var distance: float = INF
var directions: Array
var current_evade_direction: Vector3


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)


func _enter():
	directions = [top_node.global_transform.basis.z, top_node.global_transform.basis.x, -top_node.global_transform.basis.x, Vector3.UP]
	current_evade_direction = directions[randi() % directions.size()]


func _tick(delta: float):
	if is_instance_valid(manager.target):
		distance = top_node.global_transform.origin.distance_to(manager.target_last_position)
		var target_direction: Vector3 = manager.target_last_position - top_node.global_transform.origin

		if distance > dont_come_close:
			velocity = target_direction.normalized() * move_speed
		else:
			velocity = current_evade_direction * move_speed * 2

		velocity = Utilities.move_towards(top_node, manager.target_last_position, velocity, rotation_speed, delta)


func _exit():
	manager.velocity = velocity



