extends Spatial


export(Array, PackedScene) var tiles
export(PackedScene) var wall
export var length: int = 4
export var width: int = 4
export var tile_size: float = 50
export var gap: float = 0
export var wall_thickness: float = 2
var grid_instance: Spatial = null
var wall_instance: Spatial = null
var degrees: Array = [0, 90, 180, 270]


func _ready():
	# center the arena around scene origin
	translate(Vector3(-(float(length) / 2) * (tile_size + gap) + (tile_size + gap) / 2, 0, -(float(width) / 2) * (tile_size + gap) + (tile_size + gap) / 2))

	# instance floor tiles
	for x in length:
		for z in width:
			grid_instance = tiles[randi() % tiles.size()].instance()
			grid_instance.rotate_object_local(Vector3.UP, deg2rad(degrees[randi() % degrees.size()]))
			grid_instance.translation = Vector3(x * (tile_size + gap), 0, z * (tile_size + gap))
			call_deferred("add_child", grid_instance)

	# instance front and back walls
	for x in length:
		wall_instance = wall.instance()
		wall_instance.translation = Vector3(x * (tile_size + gap), 0, ((-tile_size - gap) / 2) - (wall_thickness / 2))
		call_deferred("add_child", wall_instance)

		wall_instance = wall.instance()
		wall_instance.rotate_object_local(Vector3.UP, deg2rad(180))
		wall_instance.translation = Vector3(x * (tile_size + gap), 0, ((tile_size + gap) * width) - ((tile_size + gap) / 2) + (wall_thickness / 2))
		call_deferred("add_child", wall_instance)

	# instance side walls
	for z in width:
		wall_instance = wall.instance()
		wall_instance.rotate_object_local(Vector3.UP, deg2rad(90))
		wall_instance.translation = Vector3(-((tile_size + gap) / 2) - (wall_thickness / 2), 0, z * (tile_size + gap))
		call_deferred("add_child", wall_instance)

		wall_instance = wall.instance()
		wall_instance.rotate_object_local(Vector3.UP, deg2rad(270))
		wall_instance.translation = Vector3(((tile_size + gap) * length) - ((tile_size + gap) / 2) + (wall_thickness / 2), 0, z * (tile_size + gap))
		call_deferred("add_child", wall_instance)


