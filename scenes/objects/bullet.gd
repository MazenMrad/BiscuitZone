extends Area2D

var speed
var damage
var x_angle
var y_angle


func _physics_process(delta):
	position.x += x_angle*speed*delta
	position.y += y_angle*speed*delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage)
	get_node(".").queue_free()
