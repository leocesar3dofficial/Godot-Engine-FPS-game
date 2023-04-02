extends Spatial


export var damage_amount: float = 125
var player: bool = false
var area: Area
var bodies: Array = Array() # initialize array to make it local!
var ph: Node
var distance: float = 0
var stick_to: Spatial = null
var previous_position: Vector3 = Vector3.ZERO


func _ready():
	if player:
		damage_amount *= Settings.damage_multiplier

	area =  get_node("AreaDamage")
	var fx: Spatial = get_node("EnergyExplosion")
	Utilities.start_particle_system(fx)


# warning-ignore:unused_argument
func _process(delta):
	if is_instance_valid(stick_to):
		previous_position = stick_to.global_transform.origin
		global_transform.origin = previous_position


func explode():
	bodies = area.get_overlapping_bodies()

	for b in bodies:
		# calculate damage amount by distance from the grenade for each body inside the area
		distance = self.global_transform.origin.distance_to(b.global_transform.origin)
		damage_amount *= clamp(1 - (distance / area.get_child(0).shape.radius), 0.05, 1)
		b.get_child(0).apply_damage(damage_amount, Vector3.UP, player)


func _on_TimerExplode_timeout():
	explode()


func _on_TimerDie_timeout():
	self.queue_free()
