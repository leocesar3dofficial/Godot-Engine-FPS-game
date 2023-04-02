extends Spatial


export(NodePath) var skeleton_path
export(NodePath) var bone_origin_path
export(NodePath) var top_node_path
export var bone_origin_length: float = 0.3
export(String) var bone_name = "Neck"
export var max_distance: float = 3.0
export var max_angle: float = 70.0
export var speed: float = 6.0
export var aditional_rotation: Vector3 = Vector3(0, 180, 0)

onready var target: Spatial
onready var skeleton: Skeleton = get_node(skeleton_path)
onready var bone_origin: Spatial = get_node(bone_origin_path)
onready var top_node: Spatial = get_node(top_node_path)

var bone: int
var original_bone_transform: Transform
var distance: float
var angle: float
var bone_transform: Transform
var desired_rotation: Transform


func _ready():
	bone = skeleton.find_bone(bone_name)
	original_bone_transform = skeleton.get_bone_global_pose(bone)


func _process(delta):
	if not is_instance_valid(target):
		target = get_viewport().get_camera()
		return

	skeleton.set_bone_global_pose_override(bone, bone_transform, 1.0, true)
	distance = bone_origin.global_transform.origin.distance_to(target.global_transform.origin)
	angle = Utilities.angle(top_node, target)
	bone_transform = skeleton.get_bone_global_pose(bone)
	bone_transform.origin = bone_origin.transform.origin + bone_origin.transform.basis.y.normalized() * bone_origin_length

	if distance < max_distance and angle < max_angle:
		var target_pos: Vector3 = skeleton.global_transform.xform_inv(target.global_transform.origin)
		desired_rotation = bone_transform.looking_at(target_pos, Vector3.UP)
		desired_rotation.basis = desired_rotation.basis.rotated(desired_rotation.basis.x, deg2rad(aditional_rotation.x))
		desired_rotation.basis = desired_rotation.basis.rotated(desired_rotation.basis.y, deg2rad(aditional_rotation.y))
		desired_rotation.basis = desired_rotation.basis.rotated(desired_rotation.basis.z, deg2rad(aditional_rotation.z))
		bone_transform = bone_transform.interpolate_with(desired_rotation, speed * delta)
	else:
		bone_transform = bone_transform.interpolate_with(original_bone_transform, speed * delta)


func disable_look_at_target():
	set_process(false)
	skeleton.clear_bones_global_pose_override() # disable look at

