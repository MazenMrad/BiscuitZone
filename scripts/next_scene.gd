extends Area2D


func _on_body_entered(_body):
	call_deferred("next_scene")


func next_scene():
	var current_scene_file = get_tree().current_scene.scene_file_path
	var next_level_number = current_scene_file.to_int() + 1
	if next_level_number > 8:
		RunManager.stop_run()
		get_tree().change_scene_to_file("res://scenes/UI/winning_screen.tscn")
		PauseMenu.allow_pause = false
	else:
		var next_level_path = "res://scenes/levels/level_" + str(next_level_number) + ".tscn"
		get_tree().change_scene_to_file(next_level_path)
		PauseMenu.allow_pause = true
