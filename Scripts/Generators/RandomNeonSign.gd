extends Spatial


export(Array, PackedScene) var neon_signs: Array
export var size_multiplier: int = 3


func _ready():
	var chosen_sign: Spatial = neon_signs[randi() % neon_signs.size()].instance()
	call_deferred("add_child", chosen_sign)
	scale_object_local(Vector3.ONE * size_multiplier)
