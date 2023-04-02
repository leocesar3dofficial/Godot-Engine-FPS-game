"""
Must be placed on UI scenes only, and not on scenes with MOUSE_MODE_CAPTURED
"""


extends Node


export var can_use: bool = true
export var speed: float = 750
var mouse_pos: Vector2
var width: float
var height: float
var left_joy_stick_dead_zone: float = 0.2
var temp_pos: Vector2
var viewport: Viewport


func _ready():
	viewport = get_tree().get_root()
	viewport.connect("size_changed", self, "_on_size_changed") # warning-ignore:return_value_discarded
	width = viewport.get_visible_rect().size.x
	height = viewport.get_visible_rect().size.y
	mouse_pos = Vector2(width / 2, height / 2) # center mouse cursor


func _input(event):
	# get mouse motion input
	if event is InputEventMouseMotion:
		mouse_pos = event.position


func _process(delta):
	if can_use:
		temp_pos  = Vector2(Input.get_joy_axis(0, 0), Input.get_joy_axis(0, 1))

		if temp_pos.length() > left_joy_stick_dead_zone:
			mouse_pos += temp_pos * speed * delta
		else:
			return # if warp_mouse is called every frame it prevents tooltips from appearing

		# don't let the cursor go outside the window
		mouse_pos = Vector2(clamp(mouse_pos.x, 10, width - 10), clamp(mouse_pos.y, 10, height - 10))
		viewport.warp_mouse(mouse_pos) # relative windows size (as set in ProjectSettings)


# signal of Viewport class! Updated when the game window is resized
func _on_size_changed():
	# updates the global window sizes in monitor output
	width = viewport.get_visible_rect().size.x
	height = viewport.get_visible_rect().size.y
