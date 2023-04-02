"""
loads all shaders at the beginning of the level to avoid stutter
"""


extends Spatial


func _ready():
	if Settings.shader_cache_kicked_in:
		queue_free()
	else:
		visible = true
		var particles: Array = $ParticleShaders.get_children()

		for p in particles:
			Utilities.start_particle_system(p)

		yield(get_tree().create_timer(0.3) , "timeout")

		if is_instance_valid(self):
			Settings.shader_cache_kicked_in = true
			visible = false
			queue_free()

