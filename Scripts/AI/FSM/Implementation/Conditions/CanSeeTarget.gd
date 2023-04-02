#Finite State Machine hierarchy = top_node_path/FSM/StateManager and Conditions
extends Condition


export(NodePath) var top_node_path
var top_node: Spatial
export(NodePath) var area_node_path
var area_node: Area
export(NodePath) var manager_path
var manager: StateManager
export var negate: bool
export var origin_offset: Vector3
export var target_offset: Vector3
# bit flags export: {first = 1, second = 2, third = 4, fourth = 8, so on} used in layer masks
export (int, FLAGS, "General", "Player", "Enemy") var layer_mask = 2^1 + 2^2 # general and player layers


func _ready():
	top_node = get_node(top_node_path)
	area_node = get_node(area_node_path)
	manager = get_node(manager_path)


# warning-ignore:unused_argument
func _test(delta: float):
	if is_instance_valid(manager.target):
		var agent_position = top_node.global_transform.origin
		var target_position = manager.target.global_transform.origin

		if agent_position.distance_to(target_position) > area_node.get_child(0).shape.radius:
			return negate

		var space: PhysicsDirectSpaceState = top_node.get_world().direct_space_state
		# collide with collision masks 2 and 5 = 2^2 + 2^5 = 4 + 32 = 36
		var hit: Dictionary = space.intersect_ray(agent_position + origin_offset, target_position + target_offset, [top_node], layer_mask)

		if hit:
			if hit.collider == manager.target:
				manager.target_last_position = target_position
				return !negate

	else:
		var found_target: Spatial = Utilities.find_nearest_target_in_sphere(top_node, area_node)

		if is_instance_valid(found_target):
			manager.target = found_target

	return negate
