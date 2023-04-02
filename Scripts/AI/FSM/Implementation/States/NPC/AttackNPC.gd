extends State


export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
var manager: StateManager
export var move_speed: float = 10.0
export var dont_come_close: float = 3.0
export var rotation_speed: float = 3.0
var distance: float = INF
var anim_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback
var velocity: Vector3 = Vector3()
var audio_player: AudioStreamPlayer3D
export(Resource) var attack_sound
var timer: BasicTimer = BasicTimer.new()
var directions: Dictionary = {}
var directions_keys: Array = ["back", "left", "right"]
var current_evade_direction: String


func _ready():
	timer.time = 5
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)
	anim_tree = top_node.get_node("AnimationTree")
	playback = anim_tree["parameters/playback"]
	audio_player = top_node.get_node("AudioStreamPlayer3D")


func _enter():
	velocity = manager.velocity
	directions = {"back": top_node.global_transform.basis.z, "left": -top_node.global_transform.basis.x, "right": top_node.global_transform.basis.x}
	current_evade_direction = directions_keys[randi() % directions.size()]


func _tick(delta: float):
	if is_instance_valid(manager.target):
		distance = top_node.global_transform.origin.distance_to(manager.target_last_position)

		if distance > dont_come_close and timer.test(delta) == false:

			if not audio_player.is_playing():
				audio_player.stream = attack_sound
				audio_player.play()

			var forward: Vector3 = -top_node.global_transform.basis.z
			velocity = forward * move_speed

			if playback.get_current_node() != "Running":
				# the function travel must always be called in the process function or you get an error
				playback.travel("Running")
		else:
			timer.reset()
			velocity += directions[current_evade_direction] * move_speed

			if playback.get_current_node() != "Jump":
				match current_evade_direction:
					"back":
						if playback.get_current_node() != "RunBackwards":
							playback.travel("RunBackwards")
					"left":
						if playback.get_current_node() != "StrafeLeft":
							playback.travel("StrafeLeft")
					"right":
						if playback.get_current_node() != "StrafeRight":
							playback.travel("StrafeRight")
					_:
						return

		velocity = Utilities.move_towards(top_node, manager.target_last_position, velocity, rotation_speed, delta)


func _exit():
	manager.velocity = velocity
