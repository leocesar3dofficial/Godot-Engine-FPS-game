extends Spatial


export(Array, PackedScene) var bases
export(Array, PackedScene) var middles
export(Array, PackedScene) var tops
export var probability_to_spawn: float = 0.5
export var max_number_of_middles: int = 8
var instance: Spatial = null
var previous_instance: Spatial = null
var degrees: Array = [0, 45, 90, 135, 180, 225, 270]
var current_number_of_middles: float = 1


func _ready():
	if randf() < probability_to_spawn:
		GenerateBuilding()


func GenerateBuilding():
	# instantiate base
	instance = bases[randi() % bases.size()].instance()
	instance.rotate_object_local(Vector3.UP, deg2rad(degrees[randi() % degrees.size()]))
	call_deferred("add_child", instance)

	# instantiate middle(s)
	current_number_of_middles = randi() % max_number_of_middles + 1

	for i in current_number_of_middles:
		previous_instance = instance
		instance = middles[randi() % middles.size()].instance()
		instance.rotate_object_local(Vector3.UP, deg2rad(degrees[randi() % degrees.size()]))
		instance.translation = previous_instance.translation + Vector3.UP * previous_instance.get_child(0).mesh.get_aabb().size.y
		call_deferred("add_child", instance)

	# instantiate top
	previous_instance = instance
	instance = tops[randi() % tops.size()].instance()
	instance.rotate_object_local(Vector3.UP, deg2rad(degrees[randi() % degrees.size()]))
	instance.translation = previous_instance.translation + Vector3.UP * previous_instance.get_child(0).mesh.get_aabb().size.y
	call_deferred("add_child", instance)



