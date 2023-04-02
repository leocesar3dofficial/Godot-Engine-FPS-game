extends Node


export(NodePath) var top_node_path
var kinematic_body: KinematicBody
export(NodePath) var tail_path
var tail: RayCast
export(NodePath) var manager_path
var manager: StateManager
export var gravity: float = -30
export var repel_force: float = 2


func _ready():
	kinematic_body = get_node(top_node_path)
	tail = get_node(tail_path)
	manager = get_node(manager_path)


func _process(delta):
	manager.velocity.y += gravity * delta

	if tail.is_colliding():
		manager.velocity += kinematic_body.global_transform.basis.y * repel_force * delta

	manager.velocity = kinematic_body.move_and_slide(manager.velocity, Vector3.UP, false, 1)
