extends State


func enter():
	player.anim.play("walking")


func exit():
	pass


func update(_delta: float):
	player.jumps = 0
	player.handle_falling()
	player.handle_jump()
	player.horizontal_movement()
	player.handle_roll()
	player.handle_crouching()
	handle_idle()


func handle_idle():
	if player.move_direction_x == 0:
		player.change_state(states.idle)
