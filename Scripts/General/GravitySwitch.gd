extends Area


var units_manager: UnitsManager
var level_gravity_type: int
var angle: float = 0
export(Resource) var audio_FX_in
export(Resource) var audio_FX_out


func _ready():
	units_manager = get_tree().get_root().get_node_or_null("Level/UnitsManager")

	if units_manager:
		level_gravity_type = units_manager.gravity_type


func _on_Area_body_exited(body):
	if body.name == "Player":

		if units_manager:
			angle = Utilities.angle(self, body)

			#in front (-Z)? -> normal gravity
			if angle < 90:
				units_manager.gravity_type = UnitsManager.GravityType.NORMAL
				body.flying = false
				body.deaccel = 6

				if not $AudioStreamPlayer3D.playing:
					$AudioStreamPlayer3D.stream = audio_FX_in
					$AudioStreamPlayer3D.play()
			else:
				units_manager.gravity_type = level_gravity_type
				body.flying = true
				body.deaccel = 0

				if not $AudioStreamPlayer3D.playing:
					$AudioStreamPlayer3D.stream = audio_FX_out
					$AudioStreamPlayer3D.play()
