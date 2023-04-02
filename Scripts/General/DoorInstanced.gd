extends Spatial


export(NodePath) var area_path
var area: Area
export(NodePath) var anim_player_path
var anim_player: AnimationPlayer
var on: bool = false
var in_front: bool = false
var chosen_room: bool = false
var selected_room: Spatial
export(NodePath) var audio_player_path
var audio_player: AudioStreamPlayer3D
export(Resource) var open_sound
export(Resource) var close_sound
var room_collection
var root: Spatial


func _ready():
	yield(get_tree(), "idle_frame")
	area = get_node(area_path)
	anim_player = get_node(anim_player_path)
	audio_player = get_node(audio_player_path)
	root = get_node("/root/Level")
	var error: int
	error = area.connect("body_entered", self, "_on_Area_body_entered")

	if error != OK:
		push_error("DoorInstanced._ready(): " + String(error))

	error = area.connect("body_exited", self, "_on_Area_body_exited")

	if error != OK:
		push_error("DoorInstanced._ready(): " + String(error))

	anim_player.advance(100) # keeks door DoorClose animation in the end
	room_collection = get_tree().get_current_scene().get_node("RoomCollection")


func _on_Area_body_entered(body):
	if body.name != "Player":
		return

	update_in_front(body)

	if on and in_front and not chosen_room and anim_player.get_assigned_animation() == "DoorClose":
		anim_player.play("DoorOpen", 0.25, 2)
		audio_player.stream = open_sound
		audio_player.play()
		selected_room = room_collection.rooms[randi() % room_collection.rooms.size()].instance()
		root.add_child(selected_room)
		selected_room.look_at_from_position(global_transform.origin, global_transform.origin + global_transform.basis.z, global_transform.basis.y)
		chosen_room = true


func _on_Area_body_exited(body):
	if body.name != "Player":
		return

	update_in_front(body)

	if on and not in_front and chosen_room and anim_player.get_assigned_animation() == "DoorOpen":
		anim_player.play("DoorClose", 0.25, 2)
		audio_player.stream = close_sound
		audio_player.play()
		yield(anim_player, "animation_finished")

		# prevent disabling visibility if the door is partially open
		if anim_player.get_assigned_animation() == "DoorClose":
			var current_room = get_parent()
			var current_door_transform = self.global_transform
			get_parent().remove_child(self)
			selected_room.add_child(self)
			self.global_transform = current_door_transform
			current_room.queue_free()

		on = false


func update_in_front(body: Spatial) -> void:
	in_front = Utilities.angle(self, body) < 90


func _on_Timer_timeout():
	on = true
