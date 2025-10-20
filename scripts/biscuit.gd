extends StaticBody2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	global_var.biscuits += 1
	print(global_var.biscuits)
	if RunManager.running:
		RunManager.add_biscuit()

	$".".queue_free()
