extends CanvasLayer

@export var start_screen: PackedScene
@onready var menu: Button = $CenterContainer/Menu

var allow_pause: bool = false


func _ready():
	hide()


func _process(_delta):
	if allow_pause and Input.is_action_just_pressed("escape"):
		toggle_hide()


func toggle_hide():
	visible = !visible
	get_tree().paused = visible


func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_packed(start_screen)
	hide()
