extends Spatial


export var time_to_free: float = 1
export(PackedScene) var explode_fx
export var fx_scale: float = 1
export var damage_amount: float = 10
var can_explode: bool = true


func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_Area_body_entered")
	$Timer.wait_time = time_to_free


# warning-ignore:unused_argument
func _on_Area_body_entered(body):
	if can_explode:
		can_explode = false
		var fx = explode_fx.instance()
		fx.transform = fx.transform.scaled(Vector3.ONE * fx_scale)
		fx.translation = global_transform.origin
		get_tree().get_current_scene().add_child(fx)
		Utilities.start_particle_system(fx)
		body.get_child(0).apply_damage(damage_amount, Vector3.UP)
		$Timer.start()


func _on_Timer_timeout():
	queue_free()
