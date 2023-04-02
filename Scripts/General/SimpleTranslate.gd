extends Spatial


export var axis: Vector3 = Vector3.UP
export var speed: float = 5


func _process(delta):
	translate_object_local(axis * speed * delta)
