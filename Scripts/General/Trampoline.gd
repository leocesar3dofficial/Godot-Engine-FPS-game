extends Spatial


export var force: float = 20
var audio_player: AudioStreamPlayer3D


func _ready():
	audio_player = find_node("AudioStreamPlayer3D")


func _on_Area_body_entered(body):
	if body.name == "Player":
		if body is KinematicBody:
			body.velocity = body.move_and_slide(global_transform.basis.y * force, Vector3.UP, false, 1)
		elif body is VehicleBody:
			body.engine_force = force * 10000

		if not audio_player.is_playing():
			audio_player.play()
