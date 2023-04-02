extends Spatial


export(PlayerFactory.PlayerType) var player_type
onready var player_factory: PlayerFactory = get_node("/root/Level/PlayerFactory")


func _ready():
	$Area.set_deferred("monitoring", false)


func _on_Area_body_entered(body):
	if body.script == Player:
		GlobalSounds.play_global_sound(6)
		$Area.set_deferred("monitoring", false)
		BackgroundLoader.fade_in_out()
		yield(get_tree().create_timer(0.5),"timeout")
		body.set_name("OldPlayer")
		body.queue_free()
		player_factory.create_player(player_type, global_transform.origin, rotation)
		self.queue_free()


func _on_Timer_timeout():
	# you can enter in the vehicle after a given time setted in the Timer node
	$Area.set_deferred("monitoring", true)
