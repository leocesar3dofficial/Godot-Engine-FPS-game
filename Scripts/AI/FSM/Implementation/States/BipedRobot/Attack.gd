extends State


export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
var manager: StateManager
export var move_speed: float = 10.0
export var dont_come_close: float = 3.0
export var rotation_speed: float = 3.0
export(String) var idle_anim_name = "Idle"
export(String) var walk_anim_name = "Walk"
export(String) var playback_path = "parameters/playback"
var distance: float = INF
var anim_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback
var velocity: Vector3 = Vector3()


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)
	anim_tree = top_node.get_node("AnimationTree")
	playback = anim_tree[playback_path]


func _enter():
	velocity = manager.velocity


func _tick(delta: float):
	if is_instance_valid(manager.target):
		distance = top_node.global_transform.origin.distance_to(manager.target_last_position)

		if distance > dont_come_close:
			var forward: Vector3 = -top_node.global_transform.basis.z
			velocity = forward * move_speed
			velocity = Utilities.move_towards(top_node, manager.target_last_position, velocity, rotation_speed, delta)

			if playback.get_current_node() != walk_anim_name:
				# the function travel must always be called in the process function or you get an error
				playback.travel(walk_anim_name)
		else:
#			velocity = Vector3.ZERO

			if playback.get_current_node() != idle_anim_name:
				playback.travel(idle_anim_name)


func _exit():
	manager.velocity = velocity
