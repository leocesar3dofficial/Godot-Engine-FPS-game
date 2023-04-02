extends Spatial


export var max_offset: Vector2 = Vector2(0.3, 0.3)  # Maximum hor/ver shake in units.
export var max_roll: float = 0.04  # Maximum rotation in degrees (use sparingly).
export var force: float = 8
export var frequency: float = 8
onready var noise = OpenSimplexNoise.new()
var trauma: float # Current shake strength.
var trauma_power: int = 2  # Trauma exponent. Use [2, 3].
var noise_y: float
var offset: Vector2
var shake_rotation_x: float
var shake_rotation_y: float
var seed_y: int


func _ready():
	noise.seed = randi()
	seed_y = randi()
	noise.period = 4
	noise.octaves = 2


func _process(delta):
	trauma = force * delta
	shake(delta)


func shake(delta):
	var amount = pow(trauma, trauma_power)
	noise_y += frequency * delta
	shake_rotation_x = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	shake_rotation_y = max_roll * amount * noise.get_noise_2d(seed_y, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(seed_y * 2, noise_y)
	rotate_object_local(transform.basis.x, shake_rotation_x)
	rotate_object_local(transform.basis.y, shake_rotation_y)
