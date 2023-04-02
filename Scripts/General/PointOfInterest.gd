extends Area


export var on_ready: bool = false
export var radius: float = 5000
var activated: bool = false


func _ready():
	if on_ready:
		activated = true
		monitoring = false # disable area monitoring
		Events.connect("player_entered_scene", self, "_on_player_entered_scene") # warning-ignore:return_value_discarded
	else:
		$CollisionShape.shape.radius = self.radius
		connect("body_entered", self, "_on_Area_body_entered") # warning-ignore:return_value_discarded
		connect("body_exited", self, "_on_Area_body_exited") # warning-ignore:return_value_discarded


func _on_Area_body_entered(body):
	if body.name == "Player":
		Events.emit_signal("add_pointer", self, UnitsManager.UnitsType.POINT)


func _on_Area_body_exited(body):
	if body.name == "Player":
		Events.emit_signal("remove_pointer", self)


func remove_pointer(): # used by task script: Enabler
	if activated:
		activated = false
		Events.emit_signal("remove_pointer", self)


func _on_player_entered_scene():
	if activated:
		Events.emit_signal("add_pointer", self, UnitsManager.UnitsType.POINT)
	else:
		Events.emit_signal("remove_pointer", self)
