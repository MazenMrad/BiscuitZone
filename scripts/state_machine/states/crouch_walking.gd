extends State


func enter():
	player.anim.play("crouch_walking")
	player.set_collision_to_low()


func exit():
	player.set_collision_to_default()
	player.anim.stop()


func update(_delta: float):
	player.handle_falling()
	player.handle_jump()
	player.horizontal_movement()
	player.handle_roll()

	var moving = abs(player.move_direction_x) > 0.001
	var crouch_pressed = player.key_crouch
	var can_stand := player.can_stand_up()
	var desired_state

	match [crouch_pressed, moving, can_stand]:
		[true, false, _]:
			desired_state = states.crouch
		[false, true, true]:
			desired_state = states.walk
		[false, false, true]:
			desired_state = states.idle
		[false, false, false]:
			desired_state = states.crouch

	if player.current_state != desired_state:
		player.change_state(desired_state)
