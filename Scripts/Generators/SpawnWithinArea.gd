extends Area


export(Array, PackedScene) var entities
export(UnitsManager.UnitsType) var enum_unit_type = 0
export var parent_to_self: bool = false
export var only_one_once: bool = false
export var amount: int = 5
export var radius: float = 20
export var time_interval: float = 1
onready var timer = $Timer as Timer
onready var level: Spatial = get_node("/root/Level") as Spatial
var count: int = 0
var units_manager: UnitsManager


func _ready():
	get_child(0).shape.radius = radius
	timer.wait_time = time_interval
	units_manager = get_tree().get_root().get_node_or_null("Level/UnitsManager")
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_Area_body_entered")
	# warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_Area_body_exited")
	# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "_on_Timer_timeout")


func _on_Area_body_entered(body):
	if body.name == "Player":
		if only_one_once:
			_on_Timer_timeout()
			queue_free()
			return

		if amount > 1:
			_on_Timer_timeout()
			timer.start()
		else:
			_on_Timer_timeout()


func _on_Area_body_exited(body):
	if body.name == "Player":
		count = 0
		timer.stop()


"""
Try to instanciate the provided entity
"""
func _on_Timer_timeout():
	if not is_instance_valid(units_manager):
		push_error("There must be a UnitsManager node on the Level!")
		return

	if count < amount:
		if units_manager.can_instantiate(enum_unit_type):
			count += 1
			var instance = entities[randi() % entities.size()].instance()

			if parent_to_self:
				self.add_child(instance)
			else:
				level.add_child(instance)

			instance.global_transform.origin = self.global_transform.origin
		else:
			count = 0
			timer.stop()
