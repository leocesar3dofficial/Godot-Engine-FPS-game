"""
UI elements (controls) that won't receive input must set: Mouse > Ignore
"""

extends Control


export(Array, String, FILE) var levels: Array
var thread: Thread = null
var can_load_scene: bool = true
onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var badges_children: Array = get_node("Badges").get_children()
onready var color_rect: ColorRect = $ColorRect
onready var other_UI_elements: Control = $VBoxContainer
var resource: Resource
var wait_for_signal: bool = false # load the scene, keep it ready, and wait for button to trigger signal to proceed


func _ready():
	other_UI_elements.set_visible(false)
	color_rect.set_visible(false)


func _thread_load(path):
	var loader: ResourceInteractiveLoader = ResourceLoader.load_interactive(path)
	var total: float = float(loader.get_stage_count())
	resource = null

	while true: #iterate until we have a resource
		# Update progress bar, use call deferred, which routes to main thread
		progress_bar.call_deferred("set_value", float(loader.get_stage()) * 110.0 / total)
		# Poll (does a load step)
		var result = loader.poll()
		# if OK, then load another one. If EOF, it' s done. Otherwise there was an result.
		if result == ERR_FILE_EOF:
			# Loading done, fetch resource
			resource = loader.get_resource()
			break
		elif result != OK:
			# Not OK, there was an error
			MessagePopup.show_message("There was an error loading the scene\nSee log file for more info")
			push_error("BackgroundLoader: There was an error loading the scene: " + str(result))
			break

	# Send loaded resource to the scene tree
	if wait_for_signal == false:
		call_deferred("_thread_done")
	else:
		Events.emit_signal("skip_button_visible")


func _thread_done():
	# Always wait for threads to finish, this is required on Windows
	thread.wait_to_finish()
	#Hide the progress bar
	other_UI_elements.set_visible(false)
	anim_player.play("Fadein")
	yield(anim_player, "animation_finished")
	# Instantiate next scene
	var next_scene = resource.instance()
	# Free current scene
	get_tree().current_scene.free()
	get_tree().current_scene = null
	# Add next one to root
	get_tree().get_root().add_child(next_scene)
	# Set current scene
	get_tree().current_scene = next_scene
	raise() # show on top
	anim_player.play("Fadeout")
	yield(anim_player, "animation_finished")
	color_rect.set_visible(false)
	get_tree().get_root().set_disable_input(false)
	PauseMenu.can_pause = true
	can_load_scene = true
	Events.emit_signal("ready_for_loading")


func load_scene(path, fade_speed: float = 1, _wait_for_signal: bool = false):
	if not can_load_scene:
		return

	Jukebox.crossfade_music(false) # play ambient music
	can_load_scene = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	call_deferred("raise") # show on top
	wait_for_signal = _wait_for_signal
	PauseMenu.can_pause = false
	other_UI_elements.set_visible(false)
	color_rect.set_visible(true)
	anim_player.playback_speed = fade_speed
	other_UI_elements.set_visible(true)
	progress_bar.value = 0
	thread = Thread.new()
	thread.start( self, "_thread_load", path) # warning-ignore:return_value_discarded


# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("ui_home"):
		if OS.window_fullscreen:
			OS.set_window_fullscreen(false)
		else:
			OS.set_window_fullscreen(true)

	if Input.is_action_just_pressed("god_mode"):
		get_node("/root/Level/Player/DamageReceiver").god_mode = true


func _on_LoadingSprite_visibility_changed():
	if $VBoxContainer/LoadingSprite.visible:
		$VBoxContainer/LoadingSprite.playing = true
	else:
		$VBoxContainer/LoadingSprite.playing = false


func fade_in_out():
	can_load_scene = false
	anim_player.playback_speed = 1 # resets the animation player speed to its defalt value
	raise() # show on top
	color_rect.set_visible(true)
	anim_player.play("Fadein")
	yield($AnimationPlayer, "animation_finished")
	anim_player.play("Fadeout")
	yield(anim_player, "animation_finished")
	color_rect.set_visible(false)
	can_load_scene = true


func play_badge(index: int, sound_index: int, custom_text: String = ""):
	for b in badges_children:
		b.visible = false

	if index == 3 and !custom_text.empty(): # set custom text in badge label
		badges_children[index].text = custom_text

	$BadgeAnimationPlayer.play("InOut")
	GlobalSounds.play_global_sound(sound_index)
	badges_children[index].visible = true


func DoGlitch():
	$Glitch.set_visible(true)
	$GlitchTimer.start()


func _on_GlitchTimer_timeout():
	$Glitch.set_visible(false)


func Wait_for_loading_button():
	call_deferred("_thread_done")
