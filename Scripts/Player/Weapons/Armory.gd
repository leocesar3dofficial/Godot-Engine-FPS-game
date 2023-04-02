extends Spatial
class_name Armory


export(Array, NodePath) var guns_path
export(NodePath) var audio_player_path
export(Resource) var switch_weapon_sound
export(Resource) var out_of_ammo_sound
export var can_add_gun: bool = true
export var random_first_gun: bool = true
export var initial_gun: int = 0
var guns_list: Array = Array() # All guns. Initialize array to make it local!
var guns_owned: Array = Array() # Guns found in level
var guns_owned_IDs: Array = Array()
var ammo: float = 100
var audio_player: AudioStreamPlayer3D
var current_gun: int = 0
var timer: BasicTimer = BasicTimer.new()
var can_switch: bool = false


func _ready():
	# warning-ignore:return_value_discarded
	Events.connect("increase_amno", self, "_on_increase_amno")
	# warning-ignore:return_value_discarded
	Events.connect("add_gun", self, "_on_add_gun")
	audio_player = get_node(audio_player_path)

	for gun in guns_path:
		guns_list.append(get_node(gun))

	for gun in guns_list:
		gun.visible = false

	if random_first_gun:
		initial_gun = randi() % guns_list.size()

	guns_owned_IDs.append(initial_gun)
	guns_owned.append(guns_list[initial_gun])

	guns_owned[current_gun].visible = true
	timer.time = 0.5


func _process(delta):
	can_switch = timer.test(delta)
	guns_owned[current_gun]._tick(delta)

	if can_switch and (Input.is_action_pressed("switch_weapon") or Input.is_action_just_released("switch_weapon")):
		timer.reset()
		switch_weapon(true)
		return

	if can_switch and (Input.is_action_pressed("previous_weapon") or Input.is_action_just_released("previous_weapon")):
		timer.reset()
		switch_weapon(false)


func switch_weapon(increment: bool):
	if guns_owned.size() == 1:
		return

	guns_owned[current_gun].visible = false

	if increment:
		current_gun += 1

		if current_gun + 1 > guns_owned.size():
			current_gun = 0
	else:
		current_gun -= 1

		if current_gun < 0:
			current_gun = guns_owned.size() - 1

	guns_owned[current_gun].visible = true
	guns_owned[current_gun].recoil.start_recoil(0.1, 1, 0, 20)
	audio_player.stream = switch_weapon_sound
	audio_player.play()


func out_of_ammo():
	if not audio_player.is_playing():
		audio_player.stream = out_of_ammo_sound
		audio_player.play()


func _on_increase_amno(value: int):
	ammo += value

	if ammo > 100:
		ammo = 100

	# upgrade fire power
	for gun in guns_owned:
		gun.power_up()

	Events.emit_signal("update_ammo_bar", ammo)


func _on_add_gun(gun_id: int):
	if can_add_gun:
		for gun in guns_owned:
			if gun.gun_id == gun_id:
				return

		guns_owned.append(guns_list[gun_id])
		guns_owned[current_gun].visible = false
		current_gun = guns_owned.size() - 2 # set the current gun before last added gun in the array
		guns_owned_IDs.append(gun_id)
		switch_weapon(true) # increment to the last added gun
