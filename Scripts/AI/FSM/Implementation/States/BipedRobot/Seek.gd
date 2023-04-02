extends State


export var move_speed: float = 4
export var rotation_speed: float = 4
export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
export(String) var walk_anim_name = "Walk"
export(String) var playback_path = "parameters/playback"
var manager: StateManager
var anim_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback
var velocity: Vector3 = Vector3()
var camera: Camera


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)
	anim_tree = top_node.get_node("AnimationTree")
	playback = anim_tree[playback_path]


func _tick(delta: float):
	var forward: Vector3 = -top_node.global_transform.basis.z
	velocity = forward * move_speed
	velocity = Utilities.move_towards(top_node, manager.target_last_position, velocity, rotation_speed, delta)

	if playback.get_current_node() != walk_anim_name:
		playback.travel(walk_anim_name)


func _exit():
	manager.velocity = velocity
