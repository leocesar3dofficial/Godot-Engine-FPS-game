extends Spatial


export(NodePath) var area_path
var area: Area
export(NodePath) var anim_player_path
var anim_player: AnimationPlayer
var front_scene: Spatial
var back_scene: Spatial
export(NodePath) var audio_player_path
var audio_player: AudioStreamPlayer3D
export(Resource) var open_sound
export(Resource) var close_sound


func _ready():
	area = get_node(area_path)
	audio_player = get_node(audio_player_path)
	anim_player = get_node(anim_player_path)
	anim_player.advance(100) # keeks door DoorClose animation in the end
	# warning-ignore:return_value_discarded
	area.connect("body_entered", self, "_on_Area_body_entered")
	# warning-ignore:return_value_discarded
	area.connect("body_exited", self, "_on_Area_body_exited")


func _on_Area_body_entered(body):
	if body.name == "Player" and anim_player.get_assigned_animation() == "DoorClose":
		anim_player.play("DoorOpen", 0.25, 3) # 0.25 gives the best result! If 1 -> animation pop
		audio_player.stream = open_sound
		audio_player.play()


func _on_Area_body_exited(body):
	if body.name == "Player" and anim_player.get_assigned_animation() == "DoorOpen":
		anim_player.play("DoorClose", 0.25, 3)
		audio_player.stream = open_sound
		audio_player.play()


func set_rooms(back: Spatial, front: Spatial):
	back_scene = back
	front_scene = front

