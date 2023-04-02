extends Area


func _ready():
	connect("body_entered", self, "_on_Area_body_entered") # warning-ignore:return_value_discarded


func _on_Area_body_entered(body):
	if body.name == "Player":
		set_deferred("monitoring", false)
		body.get_child(0).god_mode = true # avoid player dying on scene exit
		GlobalSounds.play_global_sound(2)
		BackgroundLoader.play_badge(0, 2) # play win badge
		BackgroundLoader.load_scene(BackgroundLoader.levels[BackgroundLoader.levels.find(get_node("/root/Level/").filename) + 1], 0.5) # go to next level/cutscene
