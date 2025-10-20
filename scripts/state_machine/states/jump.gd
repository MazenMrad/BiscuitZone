extends State


func enter():
	player.anim.play("jump")


func exit():
	pass


func update(delta: float):
	player.apply_gravity(delta)
	player.horizontal_movement()
	player.handle_roll()
	handle_jump_to_fall()


func handle_jump_to_fall():
	if player.velocity.y >= 0:
		player.change_state(states.fall)
	if !player.key_jump:
		player.velocity.y *= player.VARIABLE_JUMP_MULTIPLIER
