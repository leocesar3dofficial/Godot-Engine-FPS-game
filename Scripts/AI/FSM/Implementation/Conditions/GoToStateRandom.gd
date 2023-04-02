extends Condition


export var probability: float = 0.05


# warning-ignore:unused_argument
func _test(delta: float) -> bool:
	if randf() < probability:
		return true
	else:
		return false
