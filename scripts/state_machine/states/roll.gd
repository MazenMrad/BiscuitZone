extends State


func enter():
	player.anim.play("roll")
	player.roll_cooldown_timer.start(player.ROLL_COOLDOWN)

	player.anim.animation_finished.connect(_on_animation_finished)
	player.set_collision_to_low()
	player.is_immune = true


func update(delta: float):
	player.velocity.x = player.facing * 250
	player.horizontal_movement()
	player.handle_jump(false)
	if !player.is_on_floor():
		player.apply_gravity(delta, player.FALL_GRAVITY)


func _on_animation_finished():
	if player.anim.animation == "roll":
		if player.can_stand_up():
			player.change_state(states.idle)
		else:
			player.change_state(states.crouch)


func exit():
	player.is_immune = false
	player.set_collision_to_default()
	player.anim.animation_finished.disconnect(_on_animation_finished)
