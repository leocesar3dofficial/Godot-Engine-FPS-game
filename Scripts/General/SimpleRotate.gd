extends Spatial


export var axis: Vector3 = Vector3.UP
export var angle: float = 5
export var random: bool = false
export var random_axis: bool = false


func _ready():
	if random:
		angle += randf() * angle

	if random_axis:
		axis = Vector3(randf(), randf(), randf()).normalized()


func _process(delta):
	rotate_object_local(axis, angle * delta)
