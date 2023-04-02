extends Spatial


export var time_to_destroy: int = 1
export var use_object_pooling: bool = false
export var pool_name: String
var pool: ObjectPooling
var timer: BasicTimer = BasicTimer.new()
var audio_player: AudioStreamPlayer3D


func _ready():
	audio_player = $AudioStreamPlayer3D
	timer.time = time_to_destroy

	if use_object_pooling:
		pool = get_node("/root/Level/" + pool_name)


func _process(delta):
	if timer.test(delta):
		if use_object_pooling:
			timer.reset()
			pool.devolve_instance(self)
		else:
			self.queue_free()


func play_sound():
	audio_player.play()


