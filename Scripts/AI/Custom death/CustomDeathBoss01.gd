extends Node


var can_die: bool = true


func _ready():
	get_parent().get_node("Timer").connect("timeout", self, "_on_Timer_timeout") # warning-ignore:return_value_discarded


func initiate_custom_death():
	if can_die:
		can_die = false
		get_node("/root/Level/Player").get_child(0).god_mode = true # player can't take more damage
		get_parent().get_node("Timer").start()


func _on_Timer_timeout():
	# victory
	BackgroundLoader.play_badge(0, 2) # play win badge
	BackgroundLoader.load_scene(BackgroundLoader.levels[BackgroundLoader.levels.find(get_node("/root/Level/").filename) + 1], 0.5) # go to next level/cutscene
