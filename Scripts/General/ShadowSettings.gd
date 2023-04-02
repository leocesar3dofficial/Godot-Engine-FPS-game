extends Light


func _ready():
	Events.connect("cast_shadows", self, "_on_cast_shadows") # warning-ignore:return_value_discarded
	shadow_enabled = Settings.cast_shadows


func _on_cast_shadows():
	shadow_enabled = Settings.cast_shadows
