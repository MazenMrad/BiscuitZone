extends Area2D


func _on_body_entered(body):
	if body.velocity.y>=0:
		body.velocity.y = -500
	else:
		body.velocity.y += -500
