extends Spatial


export var tile_size: float = 2 # size of the tile in linear units/meters
export(Array, PackedScene) var tiles_array
var tile_offset: float = 3 # dimension of the tiles
var max_tiles_dist: float = 2 # the minimum tiles ahead
var player: Spatial
var tiles: Array = Array()
var dist: float = 0
var can_move: bool = false
var grid_instance: Spatial
var degrees: Array = [0, 90, 180, 270]


func _ready():
	dist = (tile_size * max_tiles_dist) - (tile_size / 2)
	translate(Vector3(-(float(tile_offset) / 2) * tile_size + tile_size / 2, 0, -(float(tile_offset) / 2) * tile_size + tile_size / 2))

	# instanciate floor tiles
	for x in tile_offset:
		for y in tile_offset:
			grid_instance = tiles_array[randi() % tiles_array.size()].instance()
			grid_instance.rotate_object_local(Vector3.FORWARD, deg2rad(degrees[randi() % degrees.size()]))
			grid_instance.translation = Vector3(x * tile_size, y * tile_size, 0)
			call_deferred("add_child", grid_instance)

	yield(get_tree(), "idle_frame")
	player = get_parent().get_node("Player")
	tiles = get_children()


# warning-ignore:unused_argument
func _process(delta):
	if is_instance_valid(player):
		for t in tiles:
			var dir: Vector3 = player.global_transform.origin - t.global_transform.origin
			var offset: Vector3 = Vector3.ZERO

			if abs(dir.x) > dist:
				offset.x = sign(dir.x) * tile_size * tile_offset

			if abs(dir.y) > dist:
				offset.y = sign(dir.y) * tile_size * tile_offset

			if abs(dir.x) > dist or abs(dir.y) > dist:
				t.global_translate(offset)
				t.rotate_object_local(Vector3.FORWARD, deg2rad(degrees[randi() % degrees.size()]))
	else:
		player = get_parent().get_node_or_null("Player")

