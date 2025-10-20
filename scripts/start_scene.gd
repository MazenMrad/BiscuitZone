extends CanvasLayer

@onready var level_picker: ItemList = %ItemList


func _ready():
	PauseMenu.allow_pause = false


func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int):
	open_level_scene(index)


func open_level_scene(index: int):
	var next_level_number = index + 1
	var next_level_path = "res://scenes/levels/level_" + str(next_level_number) + ".tscn"
	get_tree().change_scene_to_file(next_level_path)

	PauseMenu.allow_pause = true

	if next_level_number == 1:
		print("hey")
		RunManager.start_run()
	else:
		print("yeh")
		RunManager.stop_run()
