extends Node


"""
Update camera
"""
# warning-ignore:unused_signal
signal camera_shaked(force) # passing the argument is not mandatory -> default is 0.3
# warning-ignore:unused_signal
signal change_camera(target) # change to third person camera


"""
Tasks
"""
# warning-ignore:unused_signal
signal update_task(task_name, condition_name, condition_met) # condition_met: bool, can be switched on and off
# warning-ignore:unused_signal
signal execute_action(task_name, action_name)
# warning-ignore:unused_signal
signal revert_action(task_name, action_name)


"""
Update player HUD
"""
# warning-ignore:unused_signal
signal update_health_bar(value)
# warning-ignore:unused_signal
signal update_sprint_bar(sprint_gas)
# warning-ignore:unused_signal
signal update_jump_bar(jump_gas)
# warning-ignore:unused_signal
signal update_ammo_bar(value)
# warning-ignore:unused_signal
signal hud(hide)
# warning-ignore:unused_signal
signal headbobbing(on)
# warning-ignore:unused_signal
signal camerashake(on)


"""
Update GyroSphere
"""
# warning-ignore:unused_signal
signal add_pointer(unit, enum_unit_type)
# warning-ignore:unused_signal
signal remove_pointer(unit)
# warning-ignore:unused_signal
signal player_entered_scene()


"""
Update Armory
"""
# warning-ignore:unused_signal
signal increase_amno(value)
# warning-ignore:unused_signal
signal add_gun(gun_id)


"""
Other
"""
# warning-ignore:unused_signal
signal bullet_time()
# warning-ignore:unused_signal
signal skip_button_visible()
# warning-ignore:unused_signal
signal ready_for_loading()


"""
Settings
"""
# warning-ignore:unused_signal
signal show_debug_info()
# warning-ignore:unused_signal
signal cast_shadows()
# warning-ignore:unused_signal
signal update_spawn_time()
# warning-ignore:unused_signal
signal update_max_enemies()
# warning-ignore:unused_signal
signal update_look_sensitivity()
# warning-ignore:unused_signal
signal change_FOV()
# warning-ignore:unused_signal
signal invert_y()
