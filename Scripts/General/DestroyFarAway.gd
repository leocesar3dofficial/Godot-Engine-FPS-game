"""
Destroys entities that are far away from the player
"""
extends VisibilityNotifier


var time_interval: int = 5
var timer: BasicTimer = BasicTimer.new()
var camera: Camera


func _ready():
	timer.time = time_interval


func _process(delta):
	if not is_instance_valid(camera):
		camera = get_viewport().get_camera()
		return

	if timer.test(delta):
		timer.reset()

		if not is_on_screen() and global_transform.origin.distance_to(camera.global_transform.origin) > (camera.far * 0.2):
			get_owner().queue_free()
