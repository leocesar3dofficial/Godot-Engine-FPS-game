extends Spatial


export var time_to_update: float = 0.2
export var self_max_distance: float = 30
export var origin_offset: Vector3 = Vector3.ZERO
var player: Spatial
var my_timer: BasicTimer = BasicTimer.new()
var player_distance: float
onready var meshes: Array = get_children()


func _ready():
	player = get_node("root/Level/Player")
	my_timer.time = time_to_update


func _process(delta):
	if is_instance_valid(player):
		if my_timer.test(delta):
			player_distance = (global_transform.origin + origin_offset).distance_to(player.global_transform.origin)

			for mesh in meshes:
				if player_distance > mesh.lod_min_distance and player_distance < mesh.lod_max_distance:
					mesh.visible = true
				else:
					mesh.visible = false
	else:
		player = get_node("root/Level/Player")
