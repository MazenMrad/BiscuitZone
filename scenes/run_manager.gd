extends CanvasLayer

var running: bool = false
var time: float = 0.0
var biscuit: int = 0


func _process(delta: float) -> void:
	if running:
		time += delta


func start_run():
	time = 0.0
	biscuit = 0
	running = true


func stop_run():
	running = false


func add_biscuit(count: int = 1):
	if running:
		biscuit += count
