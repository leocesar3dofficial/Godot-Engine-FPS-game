extends Spatial


export var decay: float = 0.8  # How quickly the shaking stops [0, 1].
export var max_offset: Vector2 = Vector2(0.2, 0.2)  # Maximum hor/ver shake in units.
export var max_roll: float = 0.1  # Maximum rotation in radians (use sparingly).
onready var noise = OpenSimplexNoise.new()
var trauma: float  # Current shake strength.
var trauma_power: int = 2  # Trauma exponent. Use [2, 3].
var noise_y: float
var offset: Vector2
var shake_rotation: float
var original_transform: Transform
var elapsed: float


func _ready():
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	Events.connect("camera_shaked", self, "_on_camera_shaked") # warning-ignore:return_value_discarded
	Events.connect("camerashake", self, "_on_camerashake") # warning-ignore:return_value_discarded
	original_transform = transform
	set_process(Settings.camerashake);


func _process(delta):
	if elapsed > 1.5:
		trauma = 0
		elapsed = 0

	if trauma > 0:
		elapsed += delta
		trauma = max(trauma - decay * delta, 0)
		shake()
	else:
		transform = transform.interpolate_with(original_transform, 3 * delta)


func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	shake_rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	set_translation(get_translation() - Vector3(offset.x, offset.y, 0))
	rotate_object_local(transform.basis.x.normalized(), shake_rotation)


func add_trauma(amount):
	trauma = min(amount + trauma, 1.0)


func _on_camera_shaked(force: float = 0.3):
	if Settings.camerashake:
		add_trauma(force)


# warning-ignore:unused_argument
func _on_camerashake(on: bool):
	set_process(on)
