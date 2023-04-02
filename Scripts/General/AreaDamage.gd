extends Area

export var apply_damage: bool = true
export var damage: float = 999
export var once: bool = false


func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_Area_body_entered")


func _on_Area_body_entered(body):
	if apply_damage:
		var b = body.get_child(0)

		if b.has_method("apply_damage"):
			b.apply_damage(damage, body.global_transform.basis.z, false)
	else:
		body.queue_free()

	if once: # destroy area damage instance
		queue_free()
