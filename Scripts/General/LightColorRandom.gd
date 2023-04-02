extends OmniLight


var colors: Array = [Color.red, Color.green, Color.blue, Color.yellow, Color.orange]


func _ready():
	light_color = colors[randi() % colors.size()]
