extends Node


export(NodePath) var top_node_path
var top_node: KinematicBody
export(NodePath) var manager_path
var manager: StateManager
export(NodePath) var waist_ray_path
var waist_ray: RayCast
export(NodePath) var foot_ray_path
var foot_ray: RayCast
export var jump_force: float = 15
var collision_height: float = 0
export var anti_hop_time: float = 3
var time: float = 0
export(PackedScene) var jump_FX
export var FX_offset: float = -1
export var FX_scale: float = 0.5
export var animation_name: String = ""
var anim_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback


func _ready():
	top_node = get_node(top_node_path)
	manager = get_node(manager_path)
	waist_ray = get_node(waist_ray_path)
	foot_ray = get_node(foot_ray_path)

	if not animation_name.empty():
		anim_tree = top_node.get_node("AnimationTree")
		playback = anim_tree["parameters/playback"]



func _process(delta):
	time += delta

	# jump!
	if time > anti_hop_time and manager.tail.is_colliding() and foot_ray.is_colliding() and not waist_ray.is_colliding():
		manager.velocity += top_node.move_and_slide(Vector3.UP * jump_force, Vector3.UP, false, 1)
		time = 0

		if not animation_name.empty():
			playback.travel(animation_name)

		if jump_FX:
			var instance: Spatial = jump_FX.instance()
			get_tree().get_current_scene().add_child(instance)
			instance.set_translation(top_node.global_transform.origin + Vector3.UP * FX_offset)
			instance.set_scale(Vector3.ONE * FX_scale)
			Utilities.start_particle_system(instance)
