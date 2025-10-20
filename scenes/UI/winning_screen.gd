extends CanvasLayer

@export var main_menu_scene: PackedScene
@export var level_one_scene: PackedScene

@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var biscuit_label: Label = $MarginContainer/VBoxContainer/BiscuitLabel
@onready var restart_button: Button = $MarginContainer/VBoxContainer/RestartButton


func _ready():
	time_label.text = "Time: " + format_time(RunManager.time)
	biscuit_label.text = "Cookies: " + str(RunManager.biscuit)

	RunManager.stop_run()

	restart_button.pressed.connect(_on_restart_pressed)


func _on_restart_pressed():
	RunManager.start_run()
	get_tree().change_scene_to_packed(level_one_scene)


func _on_menu_pressed():
	get_tree().change_scene_to_packed(main_menu_scene)


func format_time(t: float) -> String:
	var minutes = int(t) / 60
	var seconds = int(t) % 60
	var milliseconds = int((t - int(t)) * 1000)
	return str("%02d:%02d:%03d" % [minutes, seconds, milliseconds])
