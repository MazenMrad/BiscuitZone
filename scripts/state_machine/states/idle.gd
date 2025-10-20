extends State


func enter():
	if player.previous_state == states.crouch:
		player.anim.play("stand_up")
	else:
		player.anim.play("idle")


func exit():
	pass


func update(_delta: float):
	player.handle_falling()
	player.handle_jump()
	player.handle_crouching()
	player.horizontal_movement()
	player.handle_roll()
	if player.move_direction_x != 0:
		player.change_state(states.walk)
