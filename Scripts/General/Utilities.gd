extends Node
class_name Utilities


static func find_nearest_target_in_sphere(top_node: Spatial, area: Area) -> Spatial:
	var nearest: Spatial = null
	var min_distance: float = INF
	var bodies: Array = area.get_overlapping_bodies()

	if bodies.has(top_node): bodies.erase(top_node) # remove self

	for body in bodies:
		var distance: float = top_node.global_transform.origin.distance_to(body.global_transform.origin)

		if distance < min_distance:
			min_distance = distance
			nearest = body

	return nearest


static func move_towards(self_transform: KinematicBody, target_position: Vector3, velocity: Vector3, rotation_speed: float, delta: float) -> Vector3:
	rotate_towards(self_transform, target_position, rotation_speed, delta)
#	return self_transform.move_and_slide(velocity * delta, Vector3.UP, true, 4, 0.785, false)
	return self_transform.move_and_slide(velocity * delta, Vector3.UP)


static func move_towards_free(self_transform: KinematicBody, target_position: Vector3, velocity: Vector3, rotation_speed: float, delta: float) -> Vector3:
	rotate_towards_free(self_transform, target_position, rotation_speed, delta)
#	return self_transform.move_and_slide(velocity * delta, Vector3.UP, true, 4, 0.785, false)
	return self_transform.move_and_slide(velocity * delta, Vector3.UP)


static func rotate_towards(self_transform: Spatial, target_position: Vector3, rotation_speed: float, delta: float) -> void:
	var target_direction: Vector3 = target_position - self_transform.global_transform.origin
	target_direction.y = 0

	if Vector2(target_direction.x, target_direction.z).length() < 2:
		return

	var desired_rotation: Transform = self_transform.global_transform.looking_at(target_position, Vector3.UP)
	var temp_quat = Quat(self_transform.global_transform.basis.orthonormalized().get_rotation_quat()).slerp(desired_rotation.basis.orthonormalized().get_rotation_quat(), rotation_speed * delta)
	self_transform.global_transform.basis = Basis(temp_quat)
	self_transform.rotation.x = 0
	self_transform.rotation.z = 0


static func rotate_towards_free(self_transform: Spatial, target_position: Vector3, rotation_speed: float, delta: float) -> void:
	var target_direction: Vector3 = target_position - self_transform.global_transform.origin

	if target_direction.x != 0:
		var desired_rotation: Transform = self_transform.global_transform.looking_at(target_position, Vector3.UP)
		var temp_quat = Quat(self_transform.global_transform.basis.orthonormalized().get_rotation_quat()).slerp(desired_rotation.basis.orthonormalized().get_rotation_quat(), rotation_speed * delta)
		self_transform.global_transform.basis = Basis(temp_quat)


# return a number from 0 (front -z) to 180 (back +z) or 90 (either side)
static func angle(from: Spatial, to: Spatial) -> float:
	var direction: Vector3 = (to.global_transform.origin - from.global_transform.origin).normalized()
	return rad2deg(direction.angle_to(-from.global_transform.basis.z))


static func number_format(val, _decimals = 0, _dec_point = ".", _thousands_sep = ","):
	var number = float(val)

	if(!_dec_point || !_thousands_sep):
		_dec_point = '.';
		_thousands_sep = ',';

	var roundedNumber = str(round( abs( number ) * float('1e' + str(_decimals)) ))
	var numbersString = roundedNumber
	var decimalsString = ""
	if(_decimals > 0):
		numbersString = roundedNumber.left(roundedNumber.length()-_decimals)
		decimalsString = roundedNumber.right(roundedNumber.length()-_decimals)

	var formattedNumber = ""

	while(numbersString.length() > 3):
		formattedNumber += _thousands_sep + numbersString.right(numbersString.length()-3)
		numbersString = numbersString.substr(0, numbersString.length()-3);

	var ret = ""
	if(number < 0):
		ret += "-"
	ret += numbersString + formattedNumber
	if(decimalsString != ""):
		ret += (_dec_point + decimalsString)

	return ret


static func random_int_exclusive(min_value: int, max_value: int):
	# not inclusive
	var range_size = max_value - min_value
	return (randi() % range_size) + min_value


# only works for scene files: *.tscn, avoid using it, prefer export arrays for resources!
static func list_files_in_directory(dir_path: String) -> Array:
	var files: Array = Array()
	var dir: Directory = Directory.new()
	var open_dir_error: int = dir.open(dir_path)

	if open_dir_error != OK:
		push_error("Utilities.list_files_in_directory() error: " + String(open_dir_error))
		return Array()

	var begin_list_dir_error = dir.list_dir_begin(true) # skip: ., ..

	if begin_list_dir_error != OK:
		push_error("Utilities.list_files_in_directory() error: " + String(open_dir_error))
		return Array()

	while true:
		var file: String = dir.get_next()

		if file.empty(): # end of directory
			break

		if file.get_extension() == "tscn":
			files.append(file)

	dir.list_dir_end()
	return files


static func start_particle_system(instance: Spatial):
	for p in instance.get_children():
#			if p.is_class("Particles"): # also works but it uses string argument (bad)
			if p is Particles:
				p.emitting = true
				p.restart()
			else:
				continue


static func align_with_y(transform_parameter: Transform, normal: Vector3) -> Transform:
	"""
	How to use:
		var hit = ray.get_collision_point()
		point.transform.origin = hit
		# always use transform instead of global_transform, alignment occurs in local space
		var normal = align_with_y(point.transform, ray.get_collision_normal())
		point.transform = point.transform.interpolate_with(normal, delta / 0.2)
		# note: if using the Raycast node, project the ray from the -Y axis, otherwise the function will throw orthonormalized error
	"""

	if normal != Vector3.ZERO:
		transform_parameter.basis.y = normal
		transform_parameter.basis.x = -transform_parameter.basis.z.cross(normal)
		transform_parameter.basis = transform_parameter.basis.orthonormalized()

	return transform_parameter


static func is_aligned(normalA: Vector3, normalB: Vector3, threshold: float = 0.99) -> bool:
	return normalA.dot(normalB) > threshold


static func random_direction(_global_transform: Transform, up_down: bool = false, distance: float = 100) -> Vector3:
	var directions: Array = Array()

	directions.append(_global_transform.basis.z)
	directions.append(-_global_transform.basis.z)
	directions.append(_global_transform.basis.x)
	directions.append(-_global_transform.basis.x)

	if up_down:
		directions.append(_global_transform.basis.y)
		directions.append(-_global_transform.basis.y)

	return _global_transform.origin + (directions[randi() % directions.size()].normalized() * distance)


static func random_sample_unique_numbers(min_value: int, max_value: int, how_many: int) -> Array:
	var population: Array = range(min_value, max_value)
	var sample: Array = []

	for _i in range(how_many):
		var chosen_number = randi() % population.size()
		sample.append(population[chosen_number]) # add chosen number to sample
		population.remove(chosen_number) # remove chosen number from population

	return sample


static func center_mouse(viewport: Viewport):
	var mouse_pos: Vector2 = Vector2(viewport.get_visible_rect().size.x / 2, viewport.get_visible_rect().size.y / 2)
	Input.warp_mouse_position(mouse_pos)


# dump all lines of the CSV file to an Array of Dictionaries, each line is transfromed into a dictionary, each roll to a key
static func load_CSV_file_to_Array(path: String) -> Array:
	var maindata = Array()
	var file = File.new()

	file.open(path, file.READ)

	while !file.eof_reached():
		maindata.append(file.get_csv_line())

	file.close()

	var keys: PoolStringArray = maindata[0] # store the rows names
	maindata.remove(0) # the first line of the CSV file is the row names, must be removed because it is not data
	var final_array: Array = Array()

	for entry in maindata: # store each line as an Dictionary
		if entry.size() == keys.size():
			var dic : Dictionary = Dictionary()

			for i in range(keys.size()):
				dic[keys[i]] = entry[i]

			final_array.append(dic)

	return final_array


static func pulse(offset: float, time: float, frequence: float, amplitude: float) -> float:
	return offset + sin(time * frequence) * amplitude
