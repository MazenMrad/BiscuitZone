extends Control


func _ready() -> void:
	$".".hide()


############RESTART SCENE BUTTON ##############
func _on_restart_pressed() -> void:
	print("restarting")
	get_tree().reload_current_scene()


func _on_player_died() -> void:
	print("received signal")
	$"..".global_position = $"../../Player".global_position
	$"..".make_current()
	$"../../Player".queue_free()
	$".".show()
	$biscuits.text = "biscuits collected " + str(global_var.biscuits)
