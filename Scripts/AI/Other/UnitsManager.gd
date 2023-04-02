extends Node
class_name UnitsManager


enum UnitsType {ENEMY, PLAYER, GENERAL, POINT}
enum GravityType {NORMAL, UNDERWATER, SPACE}

export(String, MULTILINE) var badge_text : String
export var max_player: int = 5
export var enemies_to_destroy: int = 0
export(GravityType) var gravity_type: int = GravityType.NORMAL
onready var max_enemy: int = Settings.max_enemies
var current_enemy: int = 0
var current_player: int = 0
var enemies_destroyed: int = 0


func _ready():
	Events.connect("update_max_enemies", self, "_on_max_enemies") # warning-ignore:return_value_discarded
	change_gravity()

	if !badge_text.empty():
		yield(get_tree().create_timer(3), "timeout")
		BackgroundLoader.play_badge(3, 7, badge_text.to_upper()) # custom text badge


func update_units(enum_unit_type: int, amount: int) -> void:
	match enum_unit_type:
		UnitsType.ENEMY:
			current_enemy += amount

			if current_enemy < 0:
				current_enemy = 0
		UnitsType.PLAYER:
			current_player += amount

			if current_player < 0:
				current_player = 0
		_:
			return


func enemy_destroyed(): # used by DamageReceiver
	if enemies_to_destroy > 0:
		enemies_destroyed += 1

		if enemies_destroyed >= enemies_to_destroy: # vitory
			enemies_to_destroy = 0 # prevent loading twice
			BackgroundLoader.play_badge(0, 2) # play win badge
			BackgroundLoader.load_scene(BackgroundLoader.levels[BackgroundLoader.levels.find(get_node("/root/Level/").filename) + 1])


func can_instantiate(enum_unit_type: int) -> bool:
	match enum_unit_type:
		UnitsType.ENEMY:
			if current_enemy < max_enemy: return true
		UnitsType.PLAYER:
			if current_player < max_player: return true
		UnitsType.GENERAL:
			return true

	return false


func change_gravity():
	match gravity_type:
		GravityType.NORMAL:
			PhysicsServer.area_set_param(get_viewport().find_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY_VECTOR, Vector3.DOWN)
		GravityType.UNDERWATER:
			PhysicsServer.area_set_param(get_viewport().find_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY_VECTOR, Vector3(0, -0.05, 0))
		GravityType.SPACE:
			PhysicsServer.area_set_param(get_viewport().find_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY_VECTOR, Vector3.ZERO)


func _on_max_enemies():
	max_enemy = Settings.max_enemies
