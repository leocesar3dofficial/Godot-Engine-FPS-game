extends Spatial


export var on: bool = false
export(Array, Material) var materials
export(NodePath) var mesh_instance_path
var mesh_instance: MeshInstance


func _ready():
	if on:
		mesh_instance = get_node(mesh_instance_path)

		for i in materials.size():
			mesh_instance.set_surface_material(i, materials[i])
