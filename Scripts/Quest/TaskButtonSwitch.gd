"""
must be in the group: Switch and must have a "Tasks" repository in the scene
"""

extends Spatial


export(String) var task_name = "ActivatePortal"
export(String) var condition_name = "ActivatePowerPlant1"
export var can_deactivate: bool = false
export(Resource) var switch_on_material
export(Resource) var switch_off_material
export(Resource) var switch_on_sound
export(Resource) var switch_off_sound
var button_activated: bool = false
var toggle: bool = false
onready var model = $Model as MeshInstance
onready var audio_player = $AudioStreamPlayer3D as AudioStreamPlayer3D


func activate_switch():
	if not can_deactivate and button_activated:
		return

	toggle = !toggle

	if not button_activated and toggle:
		button_activated = true

	if toggle:
		model.set_surface_material(0, switch_on_material)
		audio_player.stream = switch_on_sound
		audio_player.play()
		Events.emit_signal("update_task", task_name, condition_name, true)
	else:
		model.set_surface_material(0, switch_off_material)
		audio_player.stream = switch_off_sound
		audio_player.play()
		Events.emit_signal("update_task", task_name, condition_name, false)
