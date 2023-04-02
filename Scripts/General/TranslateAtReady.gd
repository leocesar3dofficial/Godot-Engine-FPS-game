""""
Move target node, when the level is ready, to a minimum and maximum distance in Godot units.
You must specify the axes in a Vector3 parameter, if any value is 0 (Zero) the node won't move in that direction.
It operates in local space.
"""


extends Node


export(NodePath) var target_path
export var axes: Vector3 = Vector3.ONE
export var min_offset: float = -1000
export var max_offset: float = 1000
export var min_distance: float = 200


func _enter_tree():
	var target = get_node(target_path) as Spatial
	var offset: Vector3 = Vector3(rand_range(min_offset, max_offset), rand_range(min_offset, max_offset), rand_range(min_offset, max_offset))
	offset *= axes
	var offset_sign: float

	# make numbers respect the minimum distance
	if abs(offset.x) < min_distance:
		offset_sign = sign(offset.x)
		offset.x = min_distance * offset_sign

	if abs(offset.y) < min_distance:
		offset_sign = sign(offset.y)
		offset.y = min_distance * offset_sign

	if abs(offset.z) < min_distance:
		offset_sign = sign(offset.z)
		offset.z = min_distance * offset_sign

	target.translate_object_local(offset)
	self.queue_free()
