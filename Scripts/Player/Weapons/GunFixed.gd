extends Gun


func fire(_projectile: PackedScene) -> void:
	Events.emit_signal("update_ammo_bar", armory.ammo)
	var p = _projectile.instance()
	p.player = true
	gun_point.add_child(p)
	p.transform = gun_point.transform
	p.rotate_object_local(p.global_transform.basis.y.normalized(), deg2rad(rand_range(-spread_angle / 2, spread_angle / 2)))
	recoil.start_recoil(0.05, -0.05, 0.05, 20)
	top_node.velocity += player_camera.global_transform.basis.z * recoil_amount * 40 # gun knockback
	audio_player.stream = gun_fire_sound_effect
	audio_player.play()
	Events.emit_signal("camera_shaked", recoil_amount * 2)
