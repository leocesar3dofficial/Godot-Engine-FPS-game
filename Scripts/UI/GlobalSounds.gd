extends AudioStreamPlayer


export(Array, Resource) var sounds


func play_global_sound(sound_index: int):
	stream = sounds[sound_index]

	if not playing:
		play()
