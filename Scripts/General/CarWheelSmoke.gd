extends Spatial


var wheel_owner: VehicleBody


func _ready():
	wheel_owner = get_owner()
	$Particles.emitting = false


# warning-ignore:unused_argument
func _process(delta):
	if wheel_owner.linear_velocity.length() > 10:
		$Particles.emitting = true
	else:
		$Particles.emitting = false
