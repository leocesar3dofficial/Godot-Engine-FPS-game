extends Spatial


var health_bar: Spatial
var sprint_bar: Spatial
var jump_bar: Spatial
var ammo_bar: Spatial


func _ready():
	Events.connect("update_health_bar", self, "_on_update_health_bar") # warning-ignore:return_value_discarded
	Events.connect("update_sprint_bar", self, "_on_update_sprint_bar") # warning-ignore:return_value_discarded
	Events.connect("update_jump_bar", self, "_on_update_jump_bar") # warning-ignore:return_value_discarded
	Events.connect("update_ammo_bar", self, "_on_update_ammo_bar") # warning-ignore:return_value_discarded
	Events.connect("change_camera", self, "_on_change_camera") # warning-ignore:return_value_discarded
	Events.connect("hud", self, "_on_hud") # warning-ignore:return_value_discarded
	health_bar = get_node("BarHealth")
	sprint_bar = get_node("BarSprint")
	jump_bar = get_node("BarJump")
	ammo_bar = get_node("BarAmno")
	visible = !Settings.hud_hide


func _on_update_health_bar(value: float):
	health_bar.scale = Vector3(value / 100, 1, 1)


func _on_update_sprint_bar(value: float):
	sprint_bar.scale = Vector3(value / 100, 1, 1)


func _on_update_jump_bar(value: float):
	jump_bar.scale = Vector3(value / 100, 1, 1)


func _on_update_ammo_bar(value: int):
	ammo_bar.scale = Vector3(float(value) / 100, 1, 1)


# warning-ignore:unused_argument
func _on_change_camera(t: Spatial): # resets HUD bar values when change camera
	if not Settings.hud_hide:
		visible = get_parent().current # if the camera is current keep it visible
		health_bar.scale = Vector3.ONE
		sprint_bar.scale = Vector3.ONE
		jump_bar.scale = Vector3.ONE
		ammo_bar.scale = Vector3.ONE


func _on_hud(hide: bool):
	visible = !hide
