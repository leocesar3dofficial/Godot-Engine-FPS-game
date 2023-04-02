extends Area


export var radius: float = 1


func _ready():
	$CollisionShape.shape.radius = radius


func _on_FreeMeIfTouch_body_entered(body):
	if body.get_owner() != self.get_owner():
		get_owner().queue_free()


func _on_Timer_timeout():
	# free this after a short while
	queue_free()
