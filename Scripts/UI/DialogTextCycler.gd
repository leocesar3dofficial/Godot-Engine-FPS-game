extends Spatial


export var random_text: bool = true
export(String) var random_text_prefix: String = "RND"
export var random_text_count: int = 3
export(Vector2) var random_text_range: Vector2 = Vector2(0, 9) # the range of texts to be picked!
export(Array, String) var text_keys
export var speed_factor: float = 10 # 10 characters per second
export(Array, Resource) var sound_fx
export var counter: int = 3
var current_text: int = 0
var text_lengths: Array = Array()
var active: bool = false
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
onready var text_label = $FloatingToolTip/Control/Label
onready var visibility_notifier = $VisibilityNotifier


func _ready():
	if random_text:
		text_keys = Array()

		# pick unique random texts from range
		for i in Utilities.random_sample_unique_numbers(int(random_text_range.x), int(random_text_range.y + 1), random_text_count):
			text_keys.append(random_text_prefix + String(i).pad_zeros(4))

	# apply the speed for each text
	for i in range(text_keys.size()):
		var length: float = float(tr(text_keys[i]).length()) / speed_factor
		if length < 3: length = 3
		text_lengths.append(length)

	$Timer.wait_time = text_lengths[0]
	$FloatingToolTip/Control.visible = false
	text_label.text = text_keys[current_text]


func _on_Area_body_entered(body):
	if body.script == Player and not active and visibility_notifier.is_on_screen():
		active = true
		$Timer.start()
		$FloatingToolTip/Control.visible = true
		$AnimationPlayer.play("Typewriter")
		play_random_sound()


func _on_Area_body_exited(body):
	if body.script == Player and active:
		active = false
		$Timer.stop()
		$FloatingToolTip/Control.visible = false
		$AnimationPlayer.stop()


func _on_Timer_timeout():
	current_text += 1

	if current_text >= text_keys.size():
		counter -= 1
		$FloatingToolTip/Control.visible = false
		current_text = 0

		if counter == 0:
			$Area.monitoring = false
			$VisibilityNotifier.disconnect("screen_entered", self, "_on_VisibilityNotifier_screen_entered")
			$VisibilityNotifier.disconnect("screen_exited", self, "_on_VisibilityNotifier_screen_exited")
			active = false
			return

		$TimerNoText.start()
		return

	set_text()

	if $VisibilityNotifier.is_on_screen():
		$FloatingToolTip/Control.visible = true
		$AnimationPlayer.play("Typewriter")


func _on_VisibilityNotifier_screen_exited():
	$FloatingToolTip/Control.visible = false
	$AnimationPlayer.stop()


func _on_VisibilityNotifier_screen_entered():
	if active:
		$FloatingToolTip/Control.visible = true
		$AnimationPlayer.play("Typewriter")


func _on_TimerNoText_timeout():
	if active:
		set_text()

		if $VisibilityNotifier.is_on_screen():
			$FloatingToolTip/Control.visible = true
			$AnimationPlayer.play("Typewriter")


func set_text():
	$Timer.wait_time = text_lengths[current_text]
	$Timer.start()
	text_label.text = text_keys[current_text]
	play_random_sound()


func play_random_sound():
	if not audio_player.is_playing():
		audio_player.stream = sound_fx[randi() % sound_fx.size()]
		audio_player.play()
