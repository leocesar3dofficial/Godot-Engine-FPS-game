"""
must be in the group: Switch
"""

extends Spatial


export(Resource) var expand_material
export(Resource) var retract_material
export(NodePath) var switch_path
export(NodePath) var anim_player_path
export(NodePath) var timer_path
onready var switch = get_node(switch_path)
onready var anim_player : AnimationPlayer = get_node(anim_player_path)
onready var timer : Timer = get_node(timer_path)
var can_use : bool = true


func _ready():
	timer.connect("timeout", self, "_on_Timer_timeout") # warning-ignore:return_value_discarded
	switch.set_surface_material(0, expand_material)
	anim_player.set_assigned_animation("Retract")
	anim_player.advance(100) # keeks the animation in the end


func activate_switch() -> void:
	if can_use:
		switch.set_surface_material(0, retract_material)
		can_use = false

		if anim_player.get_assigned_animation() == "Expand":
			timer.start(1)
			anim_player.play("Retract")
			switch.set_surface_material(0, expand_material)
		else:
			timer.start(2)
			anim_player.play("Expand")
			switch.set_surface_material(0, retract_material)


func _on_Timer_timeout():
	can_use = true
