extends RayCast


export(NodePath) var rigidbody_to_affect
export var force_strength: float = 8000
onready var rb: RigidBody = get_node(rigidbody_to_affect)
var angle: float


func _process(delta):
	angle = abs(rad2deg(global_transform.basis.get_euler().z))

	# raycast pointing upwards -> do nothing!
	if angle > 90:
		return

	# raycast pointing downwards and colliding -> push physics body back up!
	if is_colliding():
		rb.add_force(global_transform.basis.y * force_strength * delta, global_transform.origin)
