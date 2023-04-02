extends Node


var checkpoint_level: int # which level the player continues
var checkpoint_position: Vector3 = Vector3.ZERO # not saved! Just to store current level checkpoint position to spawn player if died
var save_game_filename: String = "user://game.save"


func save_game(cp_level: int, cp_position: Vector3 = Vector3.ZERO):
	checkpoint_level = cp_level
	checkpoint_position = cp_position
	var my_array: Array = Array()

	var what_to_save: Dictionary = {
		"checkpoint_level": checkpoint_level,
	}

	my_array.append(what_to_save)
	save(my_array, save_game_filename)


# you can save a array of dictionaries to a save file
func save(dicts: Array, save_filename: String, show_success_message: bool = false):
	var save_file: File = File.new()
	var open_dir_error: int = save_file.open_encrypted_with_pass(save_filename, File.WRITE, OS.get_unique_id())

	if open_dir_error != OK:
		MessagePopup.show_message("Could not save.\n" + save_filename + "\nSee log file for more info\n")
		push_error("SaveLoadGame.save() error: " + String(open_dir_error))
		return
	elif show_success_message:
		MessagePopup.show_message("Saved successfully")

	for d in dicts:
		# Store the save dictionary as a new line in the save file.
		save_file.store_line(to_json(d))

	save_file.close()


# you can load an array of dictionaries from a saved file
func load_generic(load_filename) -> Array:
	var load_array: Array = Array()
	var load_file: File = File.new()
	var open_dir_error: int = load_file.open_encrypted_with_pass(load_filename, File.READ, OS.get_unique_id())

	if open_dir_error != OK:
		MessagePopup.show_message("Could not load.\n" + load_filename + "\nSee log file for more info")
		push_error("SaveLoadGame.load_generic() error: " + String(open_dir_error))
		return load_array

	while load_file.get_position() < load_file.get_len():
		var line: Dictionary = parse_json(load_file.get_line())
		load_array.append(line)

	load_file.close()
	return load_array


func load_game():
	var load_file: File = File.new()
	var open_dir_error: int = load_file.open_encrypted_with_pass(save_game_filename, File.READ, OS.get_unique_id())

	if open_dir_error != OK:
		MessagePopup.show_message("Could not load game.\nSee log file for more info")
		push_error("SaveLoadGame.load_game() error: " + String(open_dir_error))
		return

	while load_file.get_position() < load_file.get_len():
		var line: Dictionary = parse_json(load_file.get_line())
		checkpoint_level = line["checkpoint_level"]

	load_file.close()


func save_game_file_exists() -> bool:
	var file: File = File.new()
	return file.file_exists(save_game_filename)


func delete_game_save_file():
	checkpoint_level = 0
	var dir: Directory = Directory.new()
	remove_file(dir, save_game_filename)


func remove_file(dir: Directory, path: String):
	if dir.file_exists(path):
		var remove_error: int = dir.remove(path)

		if remove_error != OK:
			MessagePopup.show_message("Could not delete game.\nSee log file for more info")
			push_error("SaveLoadGame.remove_file() error: " + String(path))
