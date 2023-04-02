extends Spatial


export(PackedScene) var first_room
export(PackedScene) var last_room
export(PackedScene) var door
export var how_many_rooms: int = 15
onready var room_collection = $RoomCollection
var previous_room: Spatial
var next_room: Spatial
var current_door: Spatial
#onready var room_weights: Array = Array()
#var total_weight: float = 0.0
var next_room_index: int = 0


func _ready():
	# (old way) prepare the probabilities of each room to be spawned, I won't use probabilities anymore, repeat rooms too much
#	init_probabilities()

	# (current) scramble rooms and then pick them sequentially, going to the first room when reach the end of the rooms list
	room_collection.rooms.shuffle()

	# create start room
	previous_room = first_room.instance()
	add_child(previous_room)

	for i in how_many_rooms:
		create_room(previous_room)

	# create last room
	var last: Spatial = last_room.instance()
	last.look_at_from_position(previous_room.get_child(0).global_transform.origin, previous_room.get_child(0).global_transform.origin - previous_room.get_child(0).global_transform.basis.z, previous_room.get_child(0).global_transform.basis.y)
	add_child(last)

	if door != null:
		current_door = door.instance()
		current_door.look_at_from_position(previous_room.get_child(0).global_transform.origin, previous_room.get_child(0).global_transform.origin - previous_room.get_child(0).global_transform.basis.z, previous_room.get_child(0).global_transform.basis.y)
		current_door.set_rooms(previous_room, last)
		add_child(current_door)


func create_room(previous: Spatial):
	if door != null:
		current_door = door.instance()
		current_door.look_at_from_position(previous.get_child(0).global_transform.origin, previous.get_child(0).global_transform.origin - previous.get_child(0).global_transform.basis.z, previous.get_child(0).global_transform.basis.y)
		add_child(current_door)

	if next_room_index >= room_collection.rooms.size(): # reached the last room in the collection -> go to the first one again
		next_room_index = 0

	next_room = room_collection.rooms[next_room_index].instance()
#	next_room = room_collection.rooms[pick_room_weighted()].instance()
	next_room.look_at_from_position(previous.get_child(0).global_transform.origin, previous.get_child(0).global_transform.origin - previous.get_child(0).global_transform.basis.z, previous.get_child(0).global_transform.basis.y)
	add_child(next_room)

	if door != null:
		current_door.set_rooms(previous, next_room)

	previous_room = next_room
	next_room_index += 1


#func init_probabilities() -> void:
#	# Reset total_weight to make sure it holds the correct value after initialization
#	total_weight = 0.0
#	# Iterate through the objects
#	for i in room_collection.rooms.size():
#		# Take current object weight and accumulate it
#		total_weight += room_collection.probabilities[i]
#		# Take current sum and assign to the object.
#		room_weights.append(total_weight)


#func pick_room_weighted() -> int:
#	# Roll the number
#	var roll: float = rand_range(0.0, total_weight)
#	# Now search for the first with acc_weight > roll
#	for i in room_collection.rooms.size():
#		if (room_weights[i] > roll):
#			return i
#
#	# If here, something weird happened, but the function has to return something.
#	return randi() % room_collection.rooms.size()
