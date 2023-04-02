extends Spatial


export(NodePath) var player_path
var player: Player
export var bobFrequency: float = 10
export var bobSharpness: float = 10
export var defaultBobAmount: float = 0.05
export(String) var sprint_input = "sprint"
export var run_multiplier: float = 1.5
var m_WeaponBobFactor: float = 1
var m_LastCharacterPosition: Vector3
var time: float = 0
var characterMovementFactor: float = 0


func _ready():
	player = get_node(player_path)


func _process(delta):
	time += delta
	var playerCharacterVelocity: Vector3 = (player.get_global_transform().origin - m_LastCharacterPosition) / delta
	var multiplier: float = 1

	if Input.is_action_pressed(sprint_input):
		multiplier = run_multiplier

	if player.current_ground_state == player.GroundStates.GROUNDED and not player.is_on_platform:
		m_WeaponBobFactor = playerCharacterVelocity.length() / (player.max_speed / multiplier)
	else: m_WeaponBobFactor = 0

	characterMovementFactor = lerp(characterMovementFactor, m_WeaponBobFactor, bobSharpness * delta)
	
	if is_nan(characterMovementFactor):
		characterMovementFactor = 0

	var hBobValue: float = sin(time * bobFrequency) * defaultBobAmount * characterMovementFactor
	var vBobValue: float = ((sin((time * bobFrequency) * 2) * 0.5) + 0.5) * defaultBobAmount * characterMovementFactor
	translation = Vector3(hBobValue, abs(vBobValue), translation.z)

	m_LastCharacterPosition = player.get_global_transform().origin
