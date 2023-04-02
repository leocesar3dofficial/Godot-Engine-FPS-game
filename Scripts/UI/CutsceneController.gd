extends Spatial


var cameras: Array
var cameras_count: int
var current_camera: int = 0


func _ready():
	var childs: Array = get_children()

	for child in childs:
		if child is Camera:
			cameras.append(child)

	cameras_count = cameras.size()


# warning-ignore:unused_argument
func _on_AnimationPlayer_animation_finished(anim_name):
	current_camera += 1

	if current_camera >= cameras_count:
		current_camera = 0

	$AnimationPlayer.set_current_animation(cameras[current_camera].name)
	$AnimationPlayer.advance(-100)
	$AnimationPlayer.play()
	cameras[current_camera].set_current(true)
