extends Node


export var soundtrack_on: bool = false;
export(Array, Resource) var ambient_music
export(Array, Resource) var battle_music
export var max_volume_db: float = -10
export var mute_volume_db: float = -50
export var fade_time: float = 2
var music_player_A: AudioStreamPlayer
var music_player_B: AudioStreamPlayer
var can_fade_A: bool = false
var can_fade_B: bool = false
var weight: float = 0


func _ready():
	randomize() # pick a seed for this runtime session, must be used only once when the game starts
	music_player_A = $MusicPlayerA
	music_player_B = $MusicPlayerB
	$TimerStopA.wait_time = fade_time
	$TimerStopB.wait_time = fade_time
	music_player_A.volume_db = max_volume_db
	music_player_B.volume_db = max_volume_db

	if soundtrack_on:
		music_player_A.stream = ambient_music[randi() % ambient_music.size()]
		music_player_A.play()


func _process(delta):
	if can_fade_A:
		weight += delta / fade_time
		music_player_A.volume_db = lerp(max_volume_db, mute_volume_db, weight)
		music_player_B.volume_db = lerp(mute_volume_db, max_volume_db, weight)
		return

	if can_fade_B:
		weight += delta / fade_time
		music_player_B.volume_db = lerp(max_volume_db, mute_volume_db, weight)
		music_player_A.volume_db = lerp(mute_volume_db, max_volume_db, weight)
		return


func crossfade_music(battle: bool = true):
	if soundtrack_on:
		if battle:
			if not music_player_B.playing:
				fade()
		else:
			if not music_player_A.playing:
				fade(false)


func fade(a_to_b: bool = true):
	if a_to_b:
		can_fade_A = true
		weight = 0
		$TimerStopA.start()
		music_player_B.stream = battle_music[randi() % battle_music.size()]
		music_player_B.play()
	else:
		can_fade_B = true
		weight = 0
		$TimerStopB.start()
		music_player_A.stream = ambient_music[randi() % ambient_music.size()]
		music_player_A.play()


func _on_TimerSilence_timeout():
	# check every 30sec interval
	# timer must be set to "Autostart"
	if soundtrack_on and not music_player_A.playing and not music_player_B.playing:
		music_player_A.stream = ambient_music[randi() % ambient_music.size()]
		music_player_A.play()


func _on_TimerStopB_timeout():
	# must be set to "One Shot"
	can_fade_B = false
	music_player_B.stop()
	music_player_B.volume_db = max_volume_db


func _on_TimerStopA_timeout():
	# must be set to "One Shot"
	can_fade_A = false
	music_player_A.stop()
	music_player_A.volume_db = max_volume_db


func load_samples_from_folder(path: String, is_ambient: bool):
	"""
	The path can be set this way:
	export(String, DIR) var ambient_music_folder
	export(String, DIR) var battle_music_folder
	"""

	if path != "":
		if is_ambient:
			ambient_music.clear()
		else:
			battle_music.clear()

		var dir = Directory.new()

		if dir.open(path) == OK:
			dir.list_dir_begin(true)
			var file_name = dir.get_next()

			while file_name != "":
				if not dir.current_is_dir():
					if file_name.to_lower().ends_with(".wav") or file_name.to_lower().ends_with(".ogg"):
						var resource = ResourceLoader.load(dir.get_current_dir() + "/" + file_name)

						if is_ambient:
							ambient_music.append(resource)
						else:
							battle_music.append(resource)

				file_name = dir.get_next()
