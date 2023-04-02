extends Node


export var bypass_visibility_notifier: bool = false
var visibility_notifier: VisibilityNotifier
var can_die: bool = true


func _ready():
	get_parent().get_node("Timer").connect("timeout", self, "_on_Timer_timeout") # warning-ignore:return_value_discarded

	if not bypass_visibility_notifier:
		visibility_notifier = get_owner().get_node("VisibilityNotifier")


func initiate_custom_death():
	if can_die:
		can_die = false
		get_parent().get_node("Timer").start()
		get_owner().get_node("Tail").set_enabled(false)
		get_owner().get_node("Logic/FSM/StateManager").set_process(false)


func _on_Timer_timeout():
	if bypass_visibility_notifier:
		get_owner().queue_free()
		return

	if visibility_notifier.is_on_screen() == false:
		get_owner().queue_free()
