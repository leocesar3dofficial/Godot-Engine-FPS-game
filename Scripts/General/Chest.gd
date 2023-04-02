extends Spatial


export(Array, PackedScene) var spawn_scenes
export(PackedScene) var spawn_FX
export var offset_y: float = 0
onready var area: Area = $Area as Area
onready var anim_player: AnimationPlayer = $AnimationPlayer as AnimationPlayer


func _ready():
	# warning-ignore:return_value_discarded
	area.connect("body_entered", self, "_on_Area_body_entered")


func _on_Area_body_entered(body):
	if body is Player:
		area.set_deferred("monitoring", false)
		anim_player.play("Open")
		$AudioStreamPlayer3D.play()
		var instance = spawn_scenes[randi() % spawn_scenes.size()].instance()
		instance.translation.y += offset_y
		add_child(instance)
		start_fx()


func start_fx():
	var fx = spawn_FX.instance()
	add_child(fx)
	fx.translation.y += offset_y
	fx.scale = Vector3.ONE / 2
	Utilities.start_particle_system(fx)
