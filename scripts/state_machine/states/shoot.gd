extends State


func enter():
	player.anim.stop()


func exit():
	pass


func update(delta: float):
	player.handle_falling()
	player.handle_jump()
	player.horizontal_movement()
