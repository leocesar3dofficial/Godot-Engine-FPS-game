extends Spatial


export(Array, PackedScene) var entities
export var amount: int = 4
export var spawn_scale:float = 1
var count: int = 0


func _on_Timer_timeout():
	if count < amount:
		count += 1
		var chosen: Spatial = entities[randi() % entities.size()].instance()
		chosen.translation = self.global_transform.origin
		chosen.scale *= spawn_scale
		get_tree().get_current_scene().call_deferred("add_child", chosen)
	else:
		queue_free()
