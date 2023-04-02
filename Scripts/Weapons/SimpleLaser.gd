extends RayCast


export(PackedScene) var projectile_hit
export var damage_amount: int = 10
export(NodePath) var laser_path
export(NodePath) var timer_path
export var intermitent_interval: float = 3
var ph: Node
var can_hit: bool = true
var internal_timer: BasicTimer = BasicTimer.new()
onready var laser = get_node(laser_path)
onready var timer = get_node(timer_path)
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready():
	turn_off_raycast()
	timer.connect("timeout", self, "_on_Timer_timeout")
	yield(get_tree().create_timer(10.0 * randf()) , "timeout") # give the ray a time offset
	internal_timer.time = intermitent_interval


func _process(delta):
	if internal_timer.test(delta):
		if enabled:
			turn_off_raycast()
		else:
			turn_on_raycast()

		internal_timer.reset()

	if not enabled:
		return

	if can_hit and is_colliding():
		var collider = get_collider()

		if is_instance_valid(collider):
			can_hit = false
			timer.start()

			if collider.get_child(0).has_method("apply_damage"):
				collider.get_child(0).apply_damage(damage_amount, -get_global_transform().basis.z)

			ph = projectile_hit.instance()
			get_tree().get_current_scene().add_child(ph)
			Utilities.start_particle_system(ph)
			var collision_point: Vector3 = get_collision_point()
			ph.set_translation(collision_point)
			var look_normal = collision_point + get_collision_normal()

			if look_normal.x != 0: # avoid look_at error
				ph.look_at(look_normal.sign(), Vector3.UP)


func _on_Timer_timeout(): # frequency on that the raycast is fired, defined in the timer node as a fraction of seconds
	can_hit = true # the timer must be set one_shot to false


func turn_on_raycast():
	audio_player.play()
	laser.visible = true
	enabled = true


func turn_off_raycast():
	laser.visible = false
	enabled = false
