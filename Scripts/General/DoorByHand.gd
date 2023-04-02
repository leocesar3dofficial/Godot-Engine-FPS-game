extends Spatial


onready var area: Area = $Area
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
export(Resource) var open_sound
export(Resource) var close_sound


func _ready():
	anim_player.advance(100) # keeps door DoorClose animation in the end
	# warning-ignore:return_value_discarded
	area.connect("body_entered", self, "_on_Area_body_entered")
	# warning-ignore:return_value_discarded
	area.connect("body_exited", self, "_on_Area_body_exited")


func _on_Area_body_entered(body):
	if body is Player and anim_player.get_assigned_animation() == "DoorClose":
		anim_player.play("DoorOpen", 0.25, 2)
		audio_player.stream = open_sound
		audio_player.play()


func _on_Area_body_exited(body):
	if body is Player and anim_player.get_assigned_animation() == "DoorOpen":
		anim_player.play("DoorClose", 0.25, 3)
		audio_player.stream = open_sound
		audio_player.play()
