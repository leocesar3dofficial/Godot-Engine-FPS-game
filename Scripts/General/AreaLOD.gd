extends Spatial


func _ready():
	# warning-ignore:return_value_discarded
	$Area.connect("body_entered", self, "_on_Area_body_entered")
	# warning-ignore:return_value_discarded
	$Area.connect("body_exited", self, "_on_Area_body_exited")
	visible = false


func _on_Area_body_entered(body):
	if body.name == "Player":
		visible = true


func _on_Area_body_exited(body):
	if body.name == "Player":
		visible = false
