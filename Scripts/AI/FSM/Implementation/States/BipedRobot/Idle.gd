extends State


export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
export(String) var idle_anim_name = "Idle"
export(String) var playback_path = "parameters/playback"
var manager: StateManager
var anim_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)
	anim_tree = top_node.get_node("AnimationTree")
	playback = anim_tree[playback_path]
	anim_tree.set_active(true)


func _enter():
	manager.target = null


# warning-ignore:unused_argument
func _tick(delta: float):
	if playback.get_current_node() != idle_anim_name:
		# the function travel must always be called in the process function or you get an error
		playback.travel(idle_anim_name)


func _exit():
	# choose a random place to go while has no target
	manager.target_last_position = Utilities.random_direction(top_node.global_transform)
