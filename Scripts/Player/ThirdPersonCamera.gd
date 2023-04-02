extends Spatial


export var speed: float = 10
export(NodePath) var camera_path
export(String) var environment_path = "/root/Level/WorldEnvironment"
onready var camera: Camera = get_node(camera_path) as Camera
var target: Spatial
var target_position: Vector3


func _ready():
	# warning-ignore:return_value_discarded
	Events.connect("change_camera", self, "_on_change_camera")
	# warning-ignore:return_value_discarded
	Events.connect("change_FOV", self, "_on_change_FOV")
	camera.fov = Settings.current_FOV
	camera.far = get_node(environment_path).level_distance_culling
	camera.clear_current()
	visible = false
	set_physics_process(false)


func _process(delta):
	if is_instance_valid(target):
		global_transform = global_transform.interpolate_with(target.global_transform, speed * delta)
	else:
		target = null
		global_transform = Transform()
		camera.set_enabled(false)
		camera.clear_current()
		visible = false
		set_process(false)


func _on_change_camera(t: Spatial):
	target = t
	global_transform = target.global_transform
	rotation = target.rotation
	camera.set_enabled(true)
	camera.make_current()
	Events.emit_signal("player_entered_scene")
	visible = true
	set_process(true)


func _on_change_FOV():
	if is_instance_valid(camera):
		camera.fov = Settings.current_FOV
