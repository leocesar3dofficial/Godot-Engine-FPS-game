extends CanvasLayer


var my_popup: AcceptDialog


func _ready():
	my_popup = get_child(0)


func show_message(text: String):
	my_popup.dialog_text = text
	my_popup.popup()


func _on_MessagePopup_confirmed():
	GlobalSounds.play_global_sound(1)
