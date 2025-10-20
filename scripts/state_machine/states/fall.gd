extends State


func enter():
	player.anim.play("jump")


func exit():
	pass


func update(delta: float):
	player.apply_gravity(delta, player.FALL_GRAVITY)
	player.horizontal_movement()
	player.handle_landing()
	player.handle_jump()
	player.handle_jump_buffer()
	player.handle_roll()
