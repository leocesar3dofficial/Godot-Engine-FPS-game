extends State


export var move_speed: float = 4
export var rotation_speed: float = 4
export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
var manager: StateManager
export(NodePath) var body_path
var body: Spatial
export var offset: float = 1
var velocity: Vector3 = Vector3()
var time: float = 0
var frequence: float = 15
var amplitude: float = 0.05
var camera: Camera


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)
	body = get_node(body_path)


func _enter():
	velocity = manager.velocity


func _tick(delta: float):
	time += delta
	body.translation.y = offset + cos(time * frequence) * amplitude
	var forward: Vector3 = -top_node.global_transform.basis.z
	velocity = forward * move_speed
	velocity = Utilities.move_towards(top_node, manager.target_last_position, velocity, rotation_speed, delta)


func _exit():
	manager.velocity = velocity
