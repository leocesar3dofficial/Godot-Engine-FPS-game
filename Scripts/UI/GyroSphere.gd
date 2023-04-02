extends Spatial


export(PackedScene) var pointer
export(Resource) var material_enemy
export(Resource) var material_friend
export(Resource) var material_point
var root: Spatial
var gyro: Spatial
var pointers: Dictionary = {} # Dictionary of object: pointer


func _ready():
	Events.connect("add_pointer", self, "_on_add_pointer") # warning-ignore:return_value_discarded
	Events.connect("remove_pointer", self, "_on_remove_pointer") # warning-ignore:return_value_discarded
	Events.connect("hud", self, "_on_hud") # warning-ignore:return_value_discarded
	Events.connect("change_camera", self, "_on_change_camera") # warning-ignore:return_value_discarded
	root = get_node("/root/Level")
	gyro = $GyroSphere
	visible = !Settings.hud_hide


func _process(delta): # warning-ignore:unused_argument
	# keep the GyroSphere aligned to the world/scene root
	gyro.global_transform.basis = Basis(root.global_transform.basis.get_rotation_quat())
	# maintain used object scale
	gyro.orthonormalize()


func _on_add_pointer(unit: Spatial, enum_unit_type: int):
	if unit in pointers:
		return

	var new_pointer: Spatial = pointer.instance()

	match enum_unit_type:
		UnitsManager.UnitsType.ENEMY:
			new_pointer.set_surface_material(0, material_enemy)
		UnitsManager.UnitsType.PLAYER:
			new_pointer.set_surface_material(0, material_friend)
		UnitsManager.UnitsType.POINT:
			new_pointer.set_surface_material(0, material_point)
		_:
			new_pointer.queue_free()
			return # anything else -> don't add to the GyroSphere!

	new_pointer.target = unit
	add_child(new_pointer)
	pointers[unit] = new_pointer


func _on_remove_pointer(unit: Spatial):
	if unit in pointers:
		pointers[unit].queue_free() # warning-ignore:return_value_discarded
		pointers.erase(unit)


func _on_hud(hide: bool):
	visible = !hide


# warning-ignore:unused_argument
func _on_change_camera(t: Spatial):
	if not Settings.hud_hide:
		visible = get_parent().current # if the camera is current keep it visible
