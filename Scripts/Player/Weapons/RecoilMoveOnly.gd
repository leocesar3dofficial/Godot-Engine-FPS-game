extends Spatial
class_name RecoilMoveOnly


export var recoil_time: float = 0.05
export var max_recoil_z: float = 1
var time: float
onready var original_z: float = translation.z


# called in the gun fire method
func start_recoil() -> void:
	time = recoil_time


func recoiling(delta) -> void:
	if time > 0:
		translation = Vector3(translation.x, translation.y, lerp(original_z, max_recoil_z, 0.3) )
		time -= delta
	else:
		translation = Vector3(translation.x, translation.y, lerp(translation.z, original_z, 0.1) )
		time = 0


func _process(delta):
	recoiling(delta)
