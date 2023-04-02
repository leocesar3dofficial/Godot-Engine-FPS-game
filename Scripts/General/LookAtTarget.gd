extends Spatial


export(NodePath) var target_path
export var angular_lock_z: bool = false
var target: Spatial


func _ready():
	if target_path:
		target = get_node(target_path)


# warning-ignore:unused_argument
func _process(delta):
	if is_instance_valid(target):
		look_at(target.global_transform.origin, Vector3.UP)

		if angular_lock_z:
			set_rotation(Vector3(get_rotation().x, get_rotation().y, 0))
