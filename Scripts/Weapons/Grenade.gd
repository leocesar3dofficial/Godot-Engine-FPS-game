extends RigidBody


export var damage_amount: float = 125
export var force: float = 30
export(PackedScene) var projectile_damage
export var explodes_on_contact: bool = false
export var self_force: bool = true
var area: Area
export var player: bool = false
var bodies: Array = Array() # initialize array to make it local!
var ph: Node
var distance: float = 0
var can_explode: bool = true
onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready():
	area = get_node("AreaDamage")

	if player:
		damage_amount *= Settings.damage_multiplier

	if explodes_on_contact:
		contact_monitor = true
		contacts_reported = 1

	if self_force:
		linear_velocity = -get_viewport().get_camera().get_child(0).global_transform.basis.z * force


func _on_Timer_timeout():
	explode()


func _on_Grenade_body_entered(body):
	if explodes_on_contact and body.collision_layer != 1: # don't detonate on General layer!
		explode()


func explode():
	bodies = area.get_overlapping_bodies()

	for b in bodies:
		# calculate damage amount by distance from the grenade for each body inside the area
		distance = self.global_transform.origin.distance_to(b.global_transform.origin)
		damage_amount *= clamp(1 - (distance / area.get_child(0).shape.radius), 0.05, 1)
		b.get_child(0).apply_damage(damage_amount, Vector3.UP, player)

	# instantiate FX and destroy itself
	Events.emit_signal("camera_shaked")
	ph = projectile_damage.instance()
	get_tree().get_current_scene().add_child(ph)
	ph.set_translation(self.global_transform.origin)
	ph.scale = Vector3.ONE * area.get_child(0).shape.radius
	Utilities.start_particle_system(ph)
	self.queue_free()


func play_sound():
	audio_player.play()
