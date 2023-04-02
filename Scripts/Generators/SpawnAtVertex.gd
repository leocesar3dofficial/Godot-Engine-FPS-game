"""
Must be child of the target mesh
"""
extends Node


export(Array, PackedScene) var entities
var mesh_instance: MeshInstance
export var min_spawn: int = 5
export var max_spawn: int = 10
export var min_scale: float = 0.1
export var max_scale: float = 1
export var align_with_normal: bool = true
export var random_scale: bool = true
export var change_material: bool = false
export(Array, Material) var materials


func _ready():
	mesh_instance = get_parent()

	var how_many: int = min_spawn + (randi() % ((max_spawn + 1) - min_spawn))
	if how_many == 0: how_many = randi() % 2
	var mesh: Mesh = mesh_instance.get_mesh()
	var surface_array: Array = mesh.surface_get_arrays(0)

	for i in how_many:
		var chosen: Spatial = entities[randi() % entities.size()].instance()
		chosen.scale = Vector3.ONE
		var selected_vertex_index: int = randi() % surface_array[0].size() # [0] equals vertex position array
		chosen.translation = surface_array[0][selected_vertex_index]
		chosen.rotate_object_local(Vector3.UP, deg2rad(randi() % 360))
		mesh_instance.call_deferred("add_child", chosen)

		if align_with_normal:
			var aligned_transform: Transform = Utilities.align_with_y(chosen.transform, surface_array[1][selected_vertex_index]) # [1] equals normal array
			chosen.transform = aligned_transform

		surface_array[0].remove(selected_vertex_index) # remove used vertex from the array

		if random_scale:
			chosen.scale_object_local(Vector3.ONE * max(min_scale, randf() * max_scale))

		if change_material:
			chosen.get_child(0).set_surface_material(0, materials[randi() % materials.size()])
