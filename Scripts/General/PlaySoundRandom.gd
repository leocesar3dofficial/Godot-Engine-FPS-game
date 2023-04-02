extends AudioStreamPlayer3D

export var min_interval: float = 10
var timer: BasicTimer = BasicTimer.new()


func _ready():
	timer.time = min_interval + (randf() * (min_interval / 2))


func _process(delta):
	if timer.test(delta):
		timer.reset()
		play()



