extends MeshInstance


export(Array, Resource) var textures: Array
export var unique_material: bool = false
export var material_ID: int = 0


func _ready():
	if textures.size() > 0:
		var material = get_active_material(material_ID)

		if unique_material:
				material = material.duplicate() # this turn the material unique

		var random_texture = textures[randi() % textures.size()]
		material.set_shader_param("texture_albedo", random_texture)
		set_surface_material(material_ID, material)
	else:
		push_error("ChangeAlbedoTextureRandom: assign at least one texture.")
