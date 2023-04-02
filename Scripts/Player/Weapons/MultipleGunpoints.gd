extends Gun


export(NodePath) var fire_points
var points: Array = Array()
var current_point: Spatial


func _ready():
	points = get_node(fire_points).get_children()


func fire(_projectile: PackedScene) -> void:
	Events.emit_signal("update_ammo_bar", armory.ammo)
	var p = _projectile.instance()
	p.player = true # the game player shoot this projectile (level objectives)
	get_tree().get_current_scene().add_child(p)
	current_point = points[randi() % points.size()]
	p.global_transform = current_point.global_transform
	p.rotate_object_local(p.global_transform.basis.y.normalized(), deg2rad(rand_range(-spread_angle / 2, spread_angle / 2)))


func _gun_fx(_fire_rate: float) -> void:
	current_point.get_child(0).emitting = true
	current_point.get_child(0).restart()
	time_to_fire = time + (1 / _fire_rate)



