extends Control
var button_type = null

func _ready():
	RunManager.hide()

func _on_start_pressed() -> void:
	button_type = "start"
	$fade.show()
	$fade/fade_timer.start()
	$fade/AnimationPlayer.play("fade_in")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_fade_timer_timeout() -> void:
	if button_type == "start":
		print("what the hell")
		RunManager.start_run()
		RunManager.show()
		PauseMenu.allow_pause = true
		get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
