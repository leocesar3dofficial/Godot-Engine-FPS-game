extends Spatial

export(Resource) var dust_sand_sfx
var degrees: Array = [0, 45, 90, 135, 180, 225, 270]
onready var dust_particles = $SandDust/Particles
onready var dust_particles2 = $SandDust2/Particles
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
onready var anim_player: AnimationPlayer = $DesertSnake_baked/AnimationPlayer
onready var raycast: RayCast = $DesertSnake_baked/Armature/Skeleton/BoneAttachment4/RayCast


func _ready():
	translate(Vector3.LEFT * randf() + Vector3.RIGHT * randf() * 30)
	rotate_object_local(Vector3.UP, deg2rad(degrees[randi() % degrees.size()]))
	dust_particles.restart()
	audio_player.stream = dust_sand_sfx
	audio_player.play()


func _on_Timer_timeout():
	anim_player.playback_speed += rand_range(-0.5, 1)
	anim_player.play("Action")


func start_end_dust_particles():
	audio_player.stream = dust_sand_sfx
	audio_player.play()
	dust_particles.emitting = false
	dust_particles2.restart()
	$Timer2.start()


func _on_Timer2_timeout():
	dust_particles.emitting = false
	$Timer3.start()


func _on_Timer3_timeout():
	queue_free()


func turn_on_laser():
	raycast.turn_on_raycast()


func turn_off_laser():
	raycast.turn_off_raycast()
