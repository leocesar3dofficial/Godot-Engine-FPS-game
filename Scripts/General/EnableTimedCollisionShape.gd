extends CollisionShape


export var time_to_enable: float = 1
var timer: BasicTimer = BasicTimer.new()


func _ready():
	disabled = true
	timer.time = time_to_enable


func _process(delta):
	if timer.test(delta):
		disabled = false
		set_process(false)
