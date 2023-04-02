extends Condition


export(NodePath) var top_node_path
var top_node: Spatial
export(NodePath) var manager_path
var manager: StateManager
export var shoot_range: float = 30
export var gunshot_spread: float = 4
var distance: float = 0
var angle: float = 0


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)


# warning-ignore:unused_argument
func _test(delta: float):
	if is_instance_valid(manager.target):
		angle = Utilities.angle(top_node, manager.target)
		distance = top_node.global_transform.origin.distance_to(manager.target.global_transform.origin)

		if distance < shoot_range and angle < (gunshot_spread / 2):
			return true

	return false
