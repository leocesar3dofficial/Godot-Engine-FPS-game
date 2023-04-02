extends Spatial


var target: Sprite
var raycast: RayCast
var collider
var anim_player: AnimationPlayer


func _ready():
	anim_player = $AnimationPlayer
	Events.connect("hud", self, "_on_hud") # warning-ignore:return_value_discarded
	Events.connect("change_camera", self, "_on_change_camera") # warning-ignore:return_value_discarded
	target = get_node("Control/Target")
	raycast = get_node("RayCast")
	$Control.visible = !Settings.hud_hide


# warning-ignore:unused_argument
func _process(delta):
	if raycast.is_colliding():
		collider = raycast.get_collider()

		if is_instance_valid(collider):
			if !anim_player.is_playing():
				anim_player.play()

			target.visible = collider.collision_layer == 4 # is enemy?
		else:
			anim_player.stop()


func _on_hud(hide: bool):
	$Control.visible = !hide
	set_process(!hide)

	if hide:
		anim_player.stop()
	else:
		anim_player.play()


# warning-ignore:unused_argument
func _on_change_camera(t: Spatial):
	visible = get_parent().current # if the camera is current keep it visible
