extends Spatial


export var scale_min: float = 0.3
export var scale_max: float = 2
export var angle_max: float = 360


func _ready():
	rotation = Vector3(deg2rad(randf() * angle_max), deg2rad(randf() * angle_max), deg2rad(randf() * angle_max))
	scale = Vector3(rand_range(scale_min, scale_max), rand_range(scale_min, scale_max), rand_range(scale_min, scale_max))
