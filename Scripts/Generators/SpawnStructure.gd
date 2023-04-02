extends Spatial


export(Array, PackedScene) var structures
export var amount: int = 3
export var grid_size: float = 30
export var grid_dimension: float = 10
var grid_positions: Array = Array()
var degrees: Array = [0, 90, 180, 270]


func _ready():
	# generate grid positions
	var center_offset: float = (grid_size * grid_dimension) / 2

	for x in grid_dimension:
		for z in grid_dimension:
			var p = Vector3((x * grid_size) - (center_offset - (grid_size / 2)), 0, (z * grid_size) - (center_offset - (grid_size / 2)))
			grid_positions.append(p)

	if amount > pow(grid_dimension, 2): # limit the amount of structures to the squared grid dimension
		amount = int(pow(grid_dimension, 2))

	spawn()


func spawn():
	while amount > 0:
		var index: int = randi() % grid_positions.size()
		var random_p: Vector3 = grid_positions[index]
		var instance = structures[randi() % structures.size()].instance()
		instance.translation = random_p
		instance.rotate_object_local(Vector3.UP, deg2rad(degrees[randi() % degrees.size()]))
		call_deferred("add_child", instance)
		grid_positions.remove(index)
		amount -= 1
