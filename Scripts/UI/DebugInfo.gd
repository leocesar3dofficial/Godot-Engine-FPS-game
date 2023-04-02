extends Label


var times: Array = [] # Timestamps of frames rendered in the last second
var fps: float = 0 # Frames per second
var player: Spatial
var units_manager: UnitsManager


func _ready():
	# warning-ignore:return_value_discarded
	Events.connect("show_debug_info", self, "_on_show_debug_info")
	units_manager = get_node("/root/Level/UnitsManager")
	_on_show_debug_info()


func _process(_delta):
	if is_instance_valid(player):
		text = str("FPS: " + String(Performance.get_monitor(Performance.TIME_FPS))) + "\n"\
		+ str(String("DRAW CALLS: " + "%04d" % Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME))) + "\n"\
		+ str("Player position: " + String(player.global_transform.origin.snapped(Vector3(1, 1, 1)))) + "\n"\
		+ str("Current enemies: " + String(units_manager.current_enemy))
	else:
		player = get_node_or_null("/root/Level/Player")


func calculate_FPS() -> float:
	var now = OS.get_ticks_msec()

	# Remove frames older than 1 second in the `times` array
	while times.size() > 0 and times[0] <= now - 1000:
		times.pop_front()

	times.append(now)
	fps = times.size()
	return fps


func _on_show_debug_info():
	if Settings.show_debug:
		get_parent().visible = true
		set_process(true)
	else:
		get_parent().visible = false
		set_process(false)
