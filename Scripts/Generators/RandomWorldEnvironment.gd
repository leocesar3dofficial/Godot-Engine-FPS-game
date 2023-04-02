extends WorldEnvironment


export var randomize_colors: bool = true
export var level_distance_culling: float = 0
export var default_depth_of_field_values: bool = false
export var contrasted_grass_color: bool = false
export var grass_material: Resource
export var plant_material: Resource
export(Array, Resource) var grass_and_plant_textures
var random_color: Color
var gradient: Gradient = Gradient.new()
var gradient_texture: GradientTexture = GradientTexture.new()

# pulsing emission materials
onready var emission_red: Material = load("res://Materials/EmissionRed.material")
onready var emission_orange: Material = load("res://Materials/EmissionOrange.material")
onready var emission_blue: Material = load("res://Materials/EmissionBlue.material")
var rand_freq: float = rand_range(1.0, 5.0)
var rand_freq2: float = rand_range(1.0, 5.0)
var rand_freq3: float = rand_range(1.0, 5.0)
var time: float = 0


func _enter_tree():
	if level_distance_culling > 0:
		Settings.dist_cull = level_distance_culling


func _ready():
	environment.fog_depth_begin = Settings.dist_cull * 0.5
	environment.fog_depth_end = Settings.dist_cull * 0.8

	if environment.dof_blur_far_enabled and not default_depth_of_field_values:
		environment.dof_blur_far_transition = Settings.dist_cull * 0.2
		environment.dof_blur_far_distance = Settings.dist_cull

	if grass_and_plant_textures.size() > 0:
		var random_texture = grass_and_plant_textures[randi() % grass_and_plant_textures.size()]
		grass_material.set_shader_param("texture_albedo", random_texture)
		random_texture = grass_and_plant_textures[randi() % grass_and_plant_textures.size()]
		plant_material.set_shader_param("texture_albedo", random_texture)

	if randomize_colors:
		# random environment colors
		var r = randf()
		random_color = Color.from_hsv(r, 0.7, 0.45)
		environment.background_color = random_color
		environment.ambient_light_color = random_color
		environment.fog_color = random_color
		gradient.offsets = [0, 0.25, 0.55, 1]
		gradient.colors = PoolColorArray([Color.from_hsv(randf(), 1, 0.15), Color.from_hsv(0.7, 0, 0.23), Color.from_hsv(randf(), 0.5, 0.45), Color.white])
		gradient_texture.gradient = gradient
		gradient_texture.width = 64
		environment.set_adjustment_color_correction(gradient_texture)

		if grass_material and plant_material:
			if contrasted_grass_color:
				grass_material.set_shader_param("albedo", Color.from_hsv(r, 0.7, 0.66).contrasted())
				plant_material.set_shader_param("albedo", Color.from_hsv(r, 0.7, 0.66))
			else:
				grass_material.set_shader_param("albedo", Color.from_hsv(r, 0.7, 0.66))
				plant_material.set_shader_param("albedo", Color.from_hsv(r, 0.7, 0.66).contrasted())

	var direct_light: DirectionalLight = get_parent().get_node_or_null("DirectionalLight")

	if direct_light:
		direct_light.shadow_enabled = Settings.cast_shadows
		direct_light.directional_shadow_max_distance = 10
		direct_light.directional_shadow_blend_splits = true
		direct_light.directional_shadow_mode = DirectionalLight.SHADOW_PARALLEL_2_SPLITS
		direct_light.directional_shadow_depth_range = DirectionalLight.SHADOW_DEPTH_RANGE_STABLE


func _process(delta):
	time += delta
	emission_red.emission_energy = Utilities.pulse(2.0, time, rand_freq, 1.5)
	emission_orange.emission_energy = Utilities.pulse(2.0, time, rand_freq2, 1.5)
	emission_blue.emission_energy = Utilities.pulse(2.0, time, rand_freq3, 1.5)
