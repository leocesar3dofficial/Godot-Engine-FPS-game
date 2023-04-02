extends Node


func _ready():
	Events.emit_signal("camera_shaked")
