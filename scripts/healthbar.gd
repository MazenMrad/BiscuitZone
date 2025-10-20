extends TextureProgressBar
@export var player: Player
func _ready():
	update()
	
func _process(delta):
	update()
	
func update():
	value=player.current_hp
	
