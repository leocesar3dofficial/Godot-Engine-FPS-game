extends Node


export(String, MULTILINE) var badge_text : String
onready var task_name: String = self.name
onready var conditions: Array = $Conditions.get_children()
onready var actions: Array = $Actions.get_children()
var condition_met_count: int = 0


func _ready():
	if conditions.size() == 0 or actions.size() == 0:
		push_error("The task must have at least one condition and one action")


func check_task_completion(_task_name: String):
	if task_name == _task_name:
		condition_met_count = 0 # must be zero at the start of every check

		for c in conditions:
			if c.condition_met:
				condition_met_count += 1

		if condition_met_count == conditions.size():
			BackgroundLoader.play_badge(3, 7, badge_text) # achievement badge

			# execute actions!
			for a in actions:
				a.execute() # the action may be executed only once
		else:
			for a in actions:
				a.revert() # the action may be irreversible

