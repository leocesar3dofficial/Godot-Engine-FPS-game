extends Reference
class_name BasicTimer


var time: float = 1
var elapsed: float = 0


func test(delta : float) -> bool:
	elapsed += delta

	if elapsed > time:
		return true

	return false


func reset() -> void:
	elapsed = 0
