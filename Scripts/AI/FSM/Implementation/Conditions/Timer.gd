extends Condition


export var timer: float = 1
var elapsed: float = 0


func _test(delta: float):
	elapsed += delta
	
	if elapsed > timer:
		elapsed = 0
		return true
	else:
		return false
