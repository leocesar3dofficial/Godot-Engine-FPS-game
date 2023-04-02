extends MeshInstance


export var offset: Vector3
var mat: SpatialMaterial


func _ready():
	mat = get_surface_material(0)


func _process(delta):
	mat.uv1_offset += offset * delta

