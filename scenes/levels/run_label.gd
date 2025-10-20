extends Label


func _process(_delta: float) -> void:
	text = "Time: %.2f | Biscuits: %d" % [RunManager.time, RunManager.biscuit]
