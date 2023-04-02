extends Node


enum EventType {KEYBOARD, MOUSE_BUTTON, JOY_BUTTON, JOY_MOTION}

var settings_filename: String = "user://settings.save"
var keybindings_filename: String = "user://keybindings.save"
var msaa: int = Viewport.MSAA_4X
var windowed: bool = false
var show_debug: bool = false
var max_enemies: int = 3
var spawn_time: int = 10
var damage_multiplier: int = 2
var fx_volume: float = 0.8
var st_volume: float = 0.8
var cast_shadows: bool = false
var dist_cull: float = 40 # default camera far culling, not saved
var look_sensitivity: float = 0.5 # from: 0.01 to 1
var joy_horizontal_axis: int = 2 # axis 2: right, axis 0: left
var joy_vertical_axis: int = 3 # axis 3: right, axis 1: left
var invert_y: float = 1 # values: 1 or -1
var current_FOV: float = 70 # values form 70 to 100
var hud_hide: bool = false # not saved
var headbobbing: bool = false
var camerashake: bool = false
var bullettime: bool = false
var knockback: bool = false
var vsync: bool = false
var shader_cache_kicked_in: bool = false # the shader cache must be used just one time per session!


func _ready():
#	TranslationServer.set_locale("pt_BR")
#	TranslationServer.set_locale("zh_CN")

	if does_file_exists(settings_filename):
		load_settings()

	if does_file_exists(keybindings_filename):
		load_keybindings()

	apply_immediate()


func save_settings():
	var settings: Dictionary = {
		"msaa" : msaa,
		"cast_shadows" : cast_shadows,
		"windowed" : windowed,
		"show_debug" : show_debug,
		"max_enemies" : max_enemies,
		"spawn_time" : spawn_time,
		"damage_multiplier" : damage_multiplier,
		"fx_volume" : fx_volume,
		"st_volume" : st_volume,
		"look_sensitivity" : look_sensitivity,
		"joy_horizontal_axis" : joy_horizontal_axis,
		"joy_vertical_axis" : joy_vertical_axis,
		"invert_y" : invert_y,
		"current_FOV" : current_FOV,
		"headbobbing" : headbobbing,
		"camerashake" : camerashake,
		"bullettime" : bullettime,
		"knockback" : knockback,
		"vsync" : vsync
	}

	var settings_array: Array = Array()
	settings_array.append(settings)
	SaveLoadGame.save(settings_array, settings_filename, true)


func load_settings():
	var settings_array: Array = SaveLoadGame.load_generic(settings_filename)

	if settings_array.size() > 0 and settings_array[0].has("vsync"):
		msaa = settings_array[0]["msaa"]
		cast_shadows = settings_array[0]["cast_shadows"]
		windowed = settings_array[0]["windowed"]
		show_debug = settings_array[0]["show_debug"]
		max_enemies = settings_array[0]["max_enemies"]
		spawn_time = settings_array[0]["spawn_time"]
		damage_multiplier = settings_array[0]["damage_multiplier"]
		fx_volume = settings_array[0]["fx_volume"]
		st_volume = settings_array[0]["st_volume"]
		look_sensitivity = settings_array[0]["look_sensitivity"]
		joy_horizontal_axis = settings_array[0]["joy_horizontal_axis"]
		joy_vertical_axis = settings_array[0]["joy_vertical_axis"]
		invert_y = settings_array[0]["invert_y"]
		current_FOV = settings_array[0]["current_FOV"]
		headbobbing = settings_array[0]["headbobbing"]
		camerashake = settings_array[0]["camerashake"]
		bullettime = settings_array[0]["bullettime"]
		knockback = settings_array[0]["knockback"]
		vsync = settings_array[0]["vsync"]
	else:
		SaveLoadGame.remove_file(Directory.new(), settings_filename)


func does_file_exists(file_path_name: String) -> bool:
	var file: File = File.new()
	return file.file_exists(file_path_name)


func apply_immediate():
	# apply immediate settings
	OS.set_use_vsync(vsync)
	OS.set_window_fullscreen(!windowed)
	AudioServer.set_bus_volume_db(1, linear2db(fx_volume))
	AudioServer.set_bus_volume_db(2, linear2db(st_volume))

	if st_volume == 0:
		Jukebox.soundtrack_on = false
	else:
		Jukebox.soundtrack_on = true
		Jukebox.crossfade_music(false)


func save_keybindings():
	var keybindings: Dictionary = Dictionary()

	for action in InputMap.get_actions():
		for event in InputMap.get_action_list(action):
			if not keybindings.has(action):
				keybindings[action] = Array()

			var event_array = Array()
			keybindings[action].append(event_array)

			if event is InputEventKey:
				event_array.append(EventType.KEYBOARD)
				event_array.append(event.scancode)
				continue

			if event is InputEventMouseButton:
				event_array.append(EventType.MOUSE_BUTTON)
				event_array.append(event.button_index)
				continue

			if event is InputEventJoypadButton:
				event_array.append(EventType.JOY_BUTTON)
				event_array.append(event.button_index)
				continue

			if event is InputEventJoypadMotion:
				event_array.append(EventType.JOY_MOTION)
				event_array.append(event.axis)
				event_array.append(event.axis_value)

	var settings_array: Array = Array()
	settings_array.append(keybindings)
	SaveLoadGame.save(settings_array, keybindings_filename, true)


func load_keybindings():
	var keybindings: Dictionary = SaveLoadGame.load_generic(keybindings_filename)[0]

	if keybindings.size() > 0 and keybindings.has("move_forward"):
		var new_event

		for action in keybindings.keys():
			InputMap.action_erase_events(action)

			for event in keybindings[action]:
				if event[0] == EventType.KEYBOARD:
					new_event = InputEventKey.new()
					new_event.scancode = event[1]

				elif event[0] == EventType.MOUSE_BUTTON:
					new_event = InputEventMouseButton.new()
					new_event.button_index = event[1]

				elif event[0] == EventType.JOY_BUTTON:
					new_event = InputEventJoypadButton.new()
					new_event.button_index = event[1]

				elif event[0] == EventType.JOY_MOTION:
					new_event = InputEventJoypadMotion.new()
					new_event.axis = event[1]
					new_event.axis_value = event[2]

				InputMap.action_add_event(action, new_event)
	else:
		SaveLoadGame.remove_file(Directory.new(), keybindings_filename)
		return
