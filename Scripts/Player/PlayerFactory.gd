extends Spatial
class_name PlayerFactory


enum PlayerType {PLAYER, FIGHTER, TANK, CAR}
enum VehicleType {FIGHTER, TANK, CAR}

export(PlayerType) var player_type
export(PackedScene) var player
export(PackedScene) var fighter
export(PackedScene) var tank
export(PackedScene) var car
export(PackedScene) var enter_fighter
export(PackedScene) var enter_tank
export(PackedScene) var enter_car
export(PackedScene) var effects_scene
export var effects_scale: float = 1
export var in_space_or_water: bool = false
var level: Spatial


func _ready():
	level = get_node("/root/Level")
	create_player(player_type, global_transform.origin, rotation)


func create_player(_player_type: int, position: Vector3, rotation: Vector3):
	var instance

	match _player_type:
		PlayerType.PLAYER:
			instance = player.instance()
			rotation.y = rotation.y + deg2rad(180)

			if in_space_or_water: # the only two properties that need to be altered to feel like in space or water
				instance.flying = true
				instance.fly_accel = 0.5
		PlayerType.FIGHTER:
			instance = fighter.instance()
		PlayerType.TANK:
			instance = tank.instance()
		PlayerType.CAR:
			instance = car.instance()

	level.call_deferred("add_child", instance)

	if effects_scene:
		var e = effects_scene.instance() as Spatial
		e.scale_object_local(Vector3(effects_scale, effects_scale, effects_scale))
		instance.add_child(e)

	instance.translation = position
	instance.rotate_object_local(Vector3.UP, rotation.y)


func create_enter_vehicle(vehicle_type: int, position: Vector3, rotation: Vector3):
	var instance: Node

	match vehicle_type:
		VehicleType.FIGHTER:
			instance = enter_fighter.instance()
		VehicleType.TANK:
			instance = enter_tank.instance()
		VehicleType.CAR:
			instance = enter_car.instance()

	level.call_deferred("add_child", instance)
	instance.translation = position
	instance.rotate_object_local(Vector3.UP, rotation.y)
