extends Condition


export(NodePath) var ray_path
var ray: RayCast
export var time_interval: float = 1
var elapsed: float = 0


func _ready():
	ray = get_node(ray_path)


func _test(delta: float):
	elapsed += delta

	if elapsed > time_interval:
		elapsed = 0

		if ray.is_colliding():
			return true

	return false
