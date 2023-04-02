extends Particles


export var start_scale: float = 1
export var final_scale: float = 3
export var speed: float = 0.3


func _ready():
	process_material.emission_sphere_radius = start_scale


func _process(delta):
	process_material.emission_sphere_radius += (delta * speed)

	if process_material.emission_sphere_radius >= final_scale:
		set_process(false)
