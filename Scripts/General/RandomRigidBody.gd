extends RigidBody


export var force: float = 0.5
var torque: Vector3


func _ready():
	torque = Vector3(rand_range(0, force), rand_range(0, force), rand_range(0, force))
	angular_velocity = torque


func _physics_process(delta):
	apply_torque_impulse(torque * delta)
