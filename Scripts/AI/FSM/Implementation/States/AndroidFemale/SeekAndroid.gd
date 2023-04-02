extends State


export var move_speed: float = 4
export var rotation_speed: float = 4
export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
var manager: StateManager
var anim_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback
var velocity: Vector3 = Vector3()
var camera: Camera


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)
	anim_tree = top_node.get_node("AnimationTree")
	playback = anim_tree["parameters/playback"]


func _tick(delta: float):
	var forward: Vector3 = -top_node.global_transform.basis.z
	velocity = forward * move_speed
	velocity = Utilities.move_towards(top_node, manager.target_last_position, velocity, rotation_speed, delta)

	if playback.get_current_node() != "Walking":
		playback.travel("Walking")


func _exit():
	manager.velocity = velocity
