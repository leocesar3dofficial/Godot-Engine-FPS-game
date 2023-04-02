"""
this class must not be overridden!
"""


extends Node
class_name StateManager


export(NodePath) var kinematic_body_path
var kinematic_body: KinematicBody
export(NodePath) var tail_path
var tail: RayCast
export var apply_gravity: bool = true
export var gravity: float = -30
export var reset_target_time: float = 2
# warning-ignore:unused_class_variable
var target: Spatial = null
# warning-ignore:unused_class_variable
var target_last_position: Vector3 = Vector3.ONE
var states: Array = Array() # make array local
var currentState: State = null
var velocity: Vector3 = Vector3.ZERO
var timer:BasicTimer = BasicTimer.new()


func _ready():
	tail = get_node(tail_path)
	add_to_group("Units")
	kinematic_body = get_node(kinematic_body_path)

	for node in get_children():
		states.append(node)

	currentState = states[0]
	currentState._enter()
	timer.time = reset_target_time


func _process(delta):
	if timer.test(delta) and is_instance_valid(target):
		target_last_position = target.global_transform.origin
		target = null
		timer.reset()

	currentState._tick(delta)
	iterate_transitions(delta)

	if apply_gravity and is_instance_valid(kinematic_body):
		if tail.is_colliding():
			velocity.y = 0
		else:
			velocity.y += gravity * delta
			velocity = kinematic_body.move_and_slide(velocity, Vector3.UP)


func iterate_transitions(delta: float) -> void:
	for transition in currentState.transitions:
		if transition.condition._test(delta):
			currentState._exit()
			currentState = transition.target_state
			currentState._enter()
			break


