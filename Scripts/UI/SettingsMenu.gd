extends Control


func _ready():
	set_ui_video_settings()
	set_ui_difficulty_settings()
	set_ui_fps_camera()
	set_ui_audio_settings()


func _on_CheckButton_fullscreen_toggled(button_pressed):
	GlobalSounds.play_global_sound(1)
	OS.set_window_fullscreen(!button_pressed)
	Settings.windowed = button_pressed


func _on_CheckButton_debug_toggled(button_pressed):
	GlobalSounds.play_global_sound(0)
	Settings.show_debug = button_pressed
	Events.emit_signal("show_debug_info")


func _on_HSlider_enemies_value_changed(value):
	GlobalSounds.play_global_sound(0)
	find_node("Value_enemies").text = String("%02d" % value)
	Settings.max_enemies = value
	Events.emit_signal("update_max_enemies")


func _on_HSlider_spawn_value_changed(value):
	GlobalSounds.play_global_sound(0)
	find_node("Value_spawn").text = String("%02d" % value)
	Settings.spawn_time = value
	Events.emit_signal("update_spawn_time")


func _on_HSlider_damage_value_changed(value):
	GlobalSounds.play_global_sound(0)
	find_node("Value_damage").text = String("%02d" % value)
	Settings.damage_multiplier = value


func _on_HSlider_fx_value_changed(value):
	GlobalSounds.play_global_sound(1)
	find_node("Value_fx").text = String("%02d" % (value * 100)) + "%"
	AudioServer.set_bus_volume_db(1, linear2db(value))
	Settings.fx_volume = value


func _on_HSlider_st_value_changed(value):
	GlobalSounds.play_global_sound(1)
	find_node("Value_st").text = String("%02d" % (value * 100)) + "%"
	AudioServer.set_bus_volume_db(2, linear2db(value))
	Settings.st_volume = value

	if Settings.st_volume > 0:
		Jukebox.soundtrack_on = true


func _on_Button_save_pressed():
	GlobalSounds.play_global_sound(1)
	Settings.save_settings()


func _on_CheckButton_fullscreen_mouse_entered():
	find_node("CheckButton_fullscreen").grab_focus()


func _on_CheckButton_debug_mouse_entered():
	find_node("CheckButton_debug").grab_focus()


func _on_HSlider_enemies_mouse_entered():
	find_node("HSlider_enemies").grab_focus()


func _on_HSlider_spawn_mouse_entered():
	find_node("HSlider_spawn").grab_focus()


func _on_HSlider_damage_mouse_entered():
	find_node("HSlider_damage").grab_focus()


func _on_HSlider_fx_mouse_entered():
	find_node("HSlider_fx").grab_focus()


func _on_HSlider_st_mouse_entered():
	find_node("HSlider_st").grab_focus()


func _on_Button_save_mouse_entered():
	find_node("Button_save").grab_focus()


func _on_CheckButton_shadows_toggled(button_pressed):
	GlobalSounds.play_global_sound(0)
	Settings.cast_shadows = button_pressed
	Events.emit_signal("cast_shadows")


func _on_CheckButton_shadows_mouse_entered():
	find_node("CheckButton_shadows").grab_focus()


func _on_OptionButton_item_selected(id):
	GlobalSounds.play_global_sound(1)
	get_viewport().msaa = id
	Settings.msaa = id


func _on_OptionButton_mouse_entered():
	find_node("OptionButton").grab_focus()


func _on_Button_low_pressed():
	GlobalSounds.play_global_sound(0)
	Settings.cast_shadows = false
	Events.emit_signal("cast_shadows")
	Settings.msaa = Viewport.MSAA_DISABLED
	set_ui_video_settings()


func _on_Button_medium_pressed():
	GlobalSounds.play_global_sound(0)
	Settings.cast_shadows = false
	Events.emit_signal("cast_shadows")
	Settings.msaa = Viewport.MSAA_4X
	set_ui_video_settings()


func _on_Button_high_pressed():
	GlobalSounds.play_global_sound(0)
	Settings.cast_shadows = true
	Events.emit_signal("cast_shadows")
	Settings.msaa = Viewport.MSAA_4X
	set_ui_video_settings()


func set_ui_video_settings():
	find_node("CheckButton_fullscreen").pressed = Settings.windowed
	find_node("CheckButton_debug").pressed = Settings.show_debug
	find_node("CheckButton_shadows").pressed = Settings.cast_shadows
	find_node("OptionButton").selected = Settings.msaa
	find_node("CheckButton_vsync").pressed = Settings.vsync


func set_ui_difficulty_settings():
	find_node("HSlider_enemies").value = Settings.max_enemies
	find_node("HSlider_spawn").value = Settings.spawn_time
	find_node("HSlider_damage").value = Settings.damage_multiplier
	find_node("Value_enemies").text = String("%02d" % Settings.max_enemies)
	find_node("Value_spawn").text = String("%02d" % Settings.spawn_time)
	find_node("Value_damage").text = String("%02d" % Settings.damage_multiplier)


func set_ui_audio_settings():
	find_node("HSlider_fx").value = Settings.fx_volume
	find_node("HSlider_st").value = Settings.st_volume
	find_node("Value_fx").text = String("%02d" % (Settings.fx_volume * 100)) + "%"
	find_node("Value_st").text = String("%02d" % (Settings.st_volume * 100)) + "%"


func set_ui_fps_camera():
	find_node("HSlider_sensitivity").value = Settings.look_sensitivity
	find_node("Value_sensitivity").text = String(Settings.look_sensitivity * 100) + "%"
	find_node("HSlider_FOV").value = Settings.current_FOV
	find_node("Value_FOV").text = String(Settings.current_FOV)

	if Settings.invert_y == -1:
		find_node("CheckButton_invertY").pressed = true
	else:
		find_node("CheckButton_invertY").pressed = false

	find_node("CheckButton_hideHUD").pressed = Settings.hud_hide
	find_node("CheckButton_headbobbing").pressed = Settings.headbobbing
	find_node("CheckButton_camerashake").pressed = Settings.camerashake
	find_node("CheckButton_bullettime").pressed = Settings.bullettime
	find_node("CheckButton_knockback").pressed = Settings.knockback


func _on_Button_easy_pressed():
	GlobalSounds.play_global_sound(0)
	Settings.max_enemies = 1
	Events.emit_signal("update_max_enemies")
	Settings.spawn_time = 15
	Events.emit_signal("update_spawn_time")
	Settings.damage_multiplier = 3
	set_ui_difficulty_settings()


func _on_Button_normal_pressed():
	GlobalSounds.play_global_sound(0)
	Settings.max_enemies = 3
	Events.emit_signal("update_max_enemies")
	Settings.spawn_time = 10
	Events.emit_signal("update_spawn_time")
	Settings.damage_multiplier = 2
	set_ui_difficulty_settings()


func _on_Button_hard_pressed():
	GlobalSounds.play_global_sound(0)
	Settings.max_enemies = 6
	Events.emit_signal("update_max_enemies")
	Settings.spawn_time = 5
	Events.emit_signal("update_spawn_time")
	Settings.damage_multiplier = 1
	set_ui_difficulty_settings()


func _on_Button_low_mouse_entered():
	find_node("Button_low").grab_focus()


func _on_Button_medium_mouse_entered():
	find_node("Button_medium").grab_focus()


func _on_Button_high_mouse_entered():
	find_node("Button_high").grab_focus()


func _on_Button_easy_mouse_entered():
	find_node("Button_easy").grab_focus()


func _on_Button_normal_mouse_entered():
	find_node("Button_normal").grab_focus()


func _on_Button_hard_mouse_entered():
	find_node("Button_hard").grab_focus()


func _on_HSlider_sensitivity_value_changed(value):
	GlobalSounds.play_global_sound(0)
	find_node("Value_sensitivity").text = String(value * 100) + "%"
	Settings.look_sensitivity = value
	Events.emit_signal("update_look_sensitivity")


func _on_HSlider_sensitivity_mouse_entered():
	find_node("HSlider_sensitivity").grab_focus()


func _on_CheckButton_invertY_toggled(button_pressed):
	GlobalSounds.play_global_sound(0)

	if button_pressed:
		Settings.invert_y = -1
	else:
		Settings.invert_y = 1

	Events.emit_signal("invert_y")


func _on_CheckButton_invertY_mouse_entered():
	find_node("CheckButton_invertY").grab_focus()


func _on_HSlider_FOV_value_changed(value):
	GlobalSounds.play_global_sound(0)
	find_node("Value_FOV").text = String(value)
	Settings.current_FOV = value
	Events.emit_signal("change_FOV")


func _on_CheckButton_leftThumb_mouse_entered():
	find_node("CheckButton_leftThumb").grab_focus()


func _on_HSlider_FOV_mouse_entered():
	find_node("HSlider_FOV").grab_focus()


func _on_CheckButton_hideHUD_toggled(button_pressed):
	GlobalSounds.play_global_sound(0)
	Settings.hud_hide = button_pressed
	Events.emit_signal("hud", button_pressed)


func _on_CheckButton_hideHUD_mouse_entered():
	find_node("CheckButton_hideHUD").grab_focus()


func _on_CheckButton_headbobbing_toggled(button_pressed):
	GlobalSounds.play_global_sound(0)
	Settings.headbobbing = button_pressed
	Events.emit_signal("headbobbing", button_pressed)


func _on_CheckButton_headbobbing_mouse_entered():
	find_node("CheckButton_headbobbing").grab_focus()


func _on_CheckButton_camerashake_toggled(button_pressed):
	GlobalSounds.play_global_sound(0)
	Settings.camerashake = button_pressed
	Events.emit_signal("camerashake", button_pressed)


func _on_CheckButton_camerashake_mouse_entered():
	find_node("CheckButton_camerashake").grab_focus()


func _on_CheckButton_bullettime_toggled(button_pressed):
	GlobalSounds.play_global_sound(0)
	Settings.bullettime = button_pressed


func _on_CheckButton_bullettime_mouse_entered():
	find_node("CheckButton_bullettime").grab_focus()


func _on_CheckButton_knockback_toggled(button_pressed):
	GlobalSounds.play_global_sound(0)
	Settings.knockback = button_pressed


func _on_CheckButton_knockback_mouse_entered():
	find_node("CheckButton_knockback").grab_focus()


func _on_CheckButton_vsync_toggled(button_pressed):
	GlobalSounds.play_global_sound(0)
	Settings.vsync = button_pressed
	OS.set_use_vsync(button_pressed)


func _on_CheckButton_vsync_mouse_entered():
	find_node("CheckButton_vsync").grab_focus()
