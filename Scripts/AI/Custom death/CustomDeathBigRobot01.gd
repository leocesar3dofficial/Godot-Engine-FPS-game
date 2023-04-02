extends Node


export(PackedScene) var explosion
export(NodePath) var head_path
onready var head : Spatial = get_node(head_path)
export(NodePath) var anim_tree_path
var anim_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback
var movement_node
onready var laser = owner.get_node("Armature/Skeleton/BoneAttachment2/Head/RayCast")
export(Array, NodePath) var queue_free_array
var can_die: bool = true


func _ready():
	$Timer.connect("timeout", self, "_on_Timer_timeout") # warning-ignore:return_value_discarded
	anim_tree = get_node(anim_tree_path)
	playback = anim_tree["parameters/StateMachine/playback"]
	movement_node = owner.get_node("Logic/FSM/StateManager")


func initiate_custom_death():
	if can_die:
		can_die = false

		# delete instant death areas
		for obj in queue_free_array:
			get_node(obj).queue_free()

		owner.get_node("AudioStreamPlayer3D").stop()
		owner.get_node("Armature").disable_look_at_target()
		owner.get_node("Armature/Skeleton/BoneAttachment2/Head/EnergyPortal").visible = false
		laser.turn_off_raycast()
		laser.set_process(false)
		movement_node.set_process(false)
		anim_tree["parameters/TimeScale/scale"] = 0.15
		playback.travel("Death")
		var instance = explosion.instance() as Spatial
		get_tree().get_current_scene().add_child(instance)
		instance.global_transform.origin = head.global_transform.origin
		instance.scale = Vector3.ONE * 9
		Utilities.start_particle_system(instance)
		get_node("/root/Level/Player").get_child(0).god_mode = true # player can't take more damage
		$Timer.start()


func _on_Timer_timeout():
	BackgroundLoader.play_badge(0, 2) # play win badge
	BackgroundLoader.load_scene(BackgroundLoader.levels[BackgroundLoader.levels.find(get_node("/root/Level/").filename) + 1])
