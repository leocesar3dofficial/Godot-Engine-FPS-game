extends VisibilityNotifier


export(Array, PackedScene) var entities
export var probability: float = 0.5
export var parent_to_self: bool = false
export var one_time: bool = false
export(UnitsManager.UnitsType) var enum_unit_type = 0 # export enum
var min_distance: float = 8
var startup_time: float = 10
var units_manager: UnitsManager
var timer: BasicTimer = BasicTimer.new()
var distance: float = 0
var camera: Camera
var level: Spatial


func _ready():
	# warning-ignore:return_value_discarded
	Events.connect("update_spawn_time", self, "_on_update_spawn_time")
	level = get_node("/root/Level")
	startup_time = Settings.spawn_time
	startup_time += randf() * (startup_time / 3)
	timer.time = startup_time
	units_manager = get_node_or_null("/root/Level/UnitsManager")

	if not is_instance_valid(units_manager):
		push_error("There must be a UnitsManager node on the Level!")
		return

	if one_time:
		set_process(false)
		create_instance()


func _process(delta):
	if timer.test(delta):
		if is_on_screen():
			return

		if is_instance_valid(camera):
			if randf() > probability:
				timer.reset()
				return

			if units_manager.can_instantiate(enum_unit_type):
				timer.reset()
				distance = global_transform.origin.distance_to(camera.global_transform.origin)

				if distance > min_distance and distance < camera.far:
					create_instance()
		else:
			camera = get_viewport().get_camera()


func create_instance() -> void:
	var chosen: Spatial = entities[randi() % entities.size()].instance()

	if parent_to_self:
		self.add_child(chosen)
	else:
		level.call_deferred("add_child", chosen)
		chosen.translation = self.global_transform.origin


func _on_update_spawn_time():
	startup_time = Settings.spawn_time
	startup_time += randf() * (startup_time / 3)
	timer.time = startup_time
