extends Node


var on: bool = false
var can_do: bool = true


func _ready():
	# warning-ignore:return_value_discarded
	Events.connect("bullet_time", self, "_on_bullet_time")


func _on_Timer_timeout():
	can_do = false
	stop()
	$CoolDown.start()


func start():
	if not on and can_do:
		on = true
		Engine.time_scale = 0.5
		AudioServer.global_rate_scale = 2
		$Timer.start()


func stop():
	if on:
		on = false
		Engine.time_scale = 1
		AudioServer.global_rate_scale = 1


func _on_bullet_time():
	if Settings.bullettime:
		start()


func _on_CoolDown_timeout():
	can_do = true
