extends Area


var units_manager: UnitsManager


func _ready():
	# warning-ignore:return_value_discarded
	self.connect("body_entered", self, "_on_Area_body_entered")
	# warning-ignore:return_value_discarded
	self.connect("body_exited", self, "_on_Area_body_exited")
	units_manager = get_tree().get_root().get_node_or_null("Level/UnitsManager")


func _on_Area_body_entered(body):
	if body.script == Player:
		body.flying = true


func _on_Area_body_exited(body):
	if 	body.script == Player and units_manager\
		and units_manager.gravity_type == UnitsManager.GravityType.NORMAL:
			body.flying = false
