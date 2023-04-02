extends Spatial
class_name ObjectPooling


export(PackedScene) var object_scene: PackedScene
export var pool_size: int = 10
var pool: Array = Array() # initialize array to make it local!


func _ready():
	for _i in range(pool_size):
		var new_object = object_scene.instance()
		new_object.set_process(false)
		new_object.visible = false
		add_child(new_object)
		pool.append(new_object)


func retrieve_instance() -> Spatial:
	for i in pool:
		if not i.visible:
			i.set_process(true)
			i.visible = true
			return i

	return null


func devolve_instance(instance: Spatial):
	instance.set_process(false)
	instance.visible = false
