extends Spatial


export(NodePath) var area_path
export(Color) var activated_color = Color.green
onready var area: Area = get_node(area_path) as Area


func _ready():
	# warning-ignore:return_value_discarded
	area.connect("body_entered", self, "_on_Area_body_entered")


func _on_Area_body_entered(body):
	if body is Player:
		var current_level_index: int = BackgroundLoader.levels.find(get_node("/root/Level/").filename)
		SaveLoadGame.save_game(current_level_index - 1, area.global_transform.origin) # save last cutscene as continue level
		$Screen.get_surface_material(0).albedo_color = activated_color
		$OmniLight.light_color = activated_color
		$AudioStreamPlayer3D.play()
		area.set_deferred("monitoring", false) # save only once per checkpoint
