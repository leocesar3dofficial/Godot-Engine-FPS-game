extends Control


onready var children: Array = get_children()


func _ready():
	visible = false


# warning-ignore:unused_argument
func _on_BadgeAnimationPlayer_animation_started(anim_name):
	visible = true


# warning-ignore:unused_argument
func _on_BadgeAnimationPlayer_animation_finished(anim_name):
	visible = false
	hide_all_badges()


func hide_all_badges():
	for b in children:
		b.visible = false
