extends Spatial


export(PackedScene) var dieFX
export(bool) var random = true
export(int) var gun_id: int = 3
var guns: Array


func _ready():
	guns = $Guns.get_children()

	for gun in guns:
		gun.visible = false

	if random:
		var chosen: int = randi() % guns.size()

		if chosen != 0:
			gun_id = chosen

	guns[gun_id].visible = true


func _on_Area_body_entered(body):
		if body is Player:
			Events.emit_signal("camera_shaked", 0.2)
			Events.emit_signal("add_gun", gun_id)
			Events.emit_signal("increase_amno", 100)

			start_fx()
			queue_free()


func start_fx():
	var fx = dieFX.instance()
	get_tree().get_current_scene().add_child(fx)
	fx.global_transform.origin = self.global_transform.origin
	fx.scale = Vector3.ONE / 2
	Utilities.start_particle_system(fx)
