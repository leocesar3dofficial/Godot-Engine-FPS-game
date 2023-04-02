extends VehicleBody


export var force: float = 1200
export var time: float = 10
export var reverse_speed: float = 3
export(Resource) var idle_sfx
export(Resource) var running_sfx
export(Resource) var high_speed_sfx
var vehicle_sounds_player: AudioStreamPlayer3D
export var steer_array: Array = [0.6, 0.3, 0, -0.3, -0.6]
var timer: BasicTimer = BasicTimer.new()
var selected_steering: float
var time_stopped: float = 0
var time_reversed: float = 0
var reverse: bool = false


func _ready():
	vehicle_sounds_player = $VehicleSound
	timer.time = time
	engine_force = force
	selected_steering = steer_array[randi() % steer_array.size()]


func _process(delta):

	if timer.test(delta):
		selected_steering = steer_array[randi() % steer_array.size()]
		timer.reset()

	steering = lerp(steering, selected_steering, delta / 3)

	if not reverse and linear_velocity.length() < reverse_speed:
		time_stopped += delta

	if time_stopped > 1:
		time_stopped = 0
		reverse = true

	if reverse:
		time_reversed += delta
		engine_force = -force * 2

		if time_reversed > 3:
			reverse = false
			time_reversed = 0
	else:
		engine_force = force

	play_vehicle_engine_sounds()


func play_vehicle_engine_sounds():
	if linear_velocity.length() > 15 and vehicle_sounds_player.stream != high_speed_sfx:
		vehicle_sounds_player.stream = high_speed_sfx
		vehicle_sounds_player.play()
		return

	if (linear_velocity.length() > 5 and linear_velocity.length() < 15)\
		and vehicle_sounds_player.stream != running_sfx:
		vehicle_sounds_player.stream = running_sfx
		vehicle_sounds_player.play()
		return

	if linear_velocity.length() < 5 and vehicle_sounds_player.stream != idle_sfx:
		vehicle_sounds_player.stream = idle_sfx
		vehicle_sounds_player.play()
		return
