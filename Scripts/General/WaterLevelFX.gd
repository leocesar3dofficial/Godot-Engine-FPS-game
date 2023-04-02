"""
For it to work it needs a Spatial in the scene with the name "WaterLevel"
"""
extends Node


export(NodePath) var water_plane_path
export(NodePath) var head_path
export(NodePath) var audio_player_path
var audio_player: AudioStreamPlayer3D
export(Resource) var splash_sound
var water_camera: MeshInstance
var head: Spatial
var submerged: bool = false
onready var water_level: Spatial = get_node_or_null("/root/Level/WaterLevel") as Spatial
var water_level_y: float


func _ready():
	water_camera = get_node(water_plane_path)
	water_camera.visible = false

	if is_instance_valid(water_level):
		head = get_node(head_path)
		audio_player = get_node(audio_player_path)
		water_level_y = water_level.global_transform.origin.y
	else:
		set_process(false)


func _process(_delta):
	if (head.global_transform.origin.y - water_level_y) < 0.1:
		water_camera.visible = true

		if not submerged and not audio_player.playing:
			audio_player.stream = splash_sound
			audio_player.play()

		submerged = true
	else:
		water_camera.visible = false
		submerged = false
