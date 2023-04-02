extends Spatial


export(Material) var activate_material
export(PackedScene) var die_fx
export var damage_amount: float = 125
var mesh: MeshInstance
var audio_player: AudioStreamPlayer3D
var active: bool = true
var area: Area
var bodies: Array = Array() # initialize array to make it local!
var ph: Node
var distance: float = 0


func _ready():
	mesh = $MeshInstance
	audio_player = $AudioStreamPlayer3D
	area = $Area
	area.connect("body_entered", self, "_on_Area_body_entered") # warning-ignore:return_value_discarded
	$Timer.connect("timeout", self, "_on_Timer_timeout") # warning-ignore:return_value_discarded


func _on_Area_body_entered(body):
	if active and body.name == "Player":
		active = false
		mesh.set_surface_material(2, activate_material)
		audio_player.play()
		$Timer.start()


func _on_Timer_timeout():
	audio_player.stop()
	explode()


func explode():
	bodies = area.get_overlapping_bodies()

	for b in bodies:
		# calculate damage amount by distance from the grenade for each body inside the area
		distance = self.global_transform.origin.distance_to(b.global_transform.origin)
		damage_amount *= clamp(1 - (distance / area.get_child(0).shape.radius), 0.05, 1)
		b.get_child(0).apply_damage(damage_amount, Vector3.UP, false)

	# instantiate FX and destroy itself
	ph = die_fx.instance()
	get_tree().get_current_scene().add_child(ph)
	Utilities.start_particle_system(ph)
	ph.set_translation(self.global_transform.origin)
	self.queue_free()
