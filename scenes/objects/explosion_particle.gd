extends CPUParticles2D

@onready var time_created = Time.get_ticks_msec()

func _ready():
	$ExplosionSound.play()

func _process(_delta):
	if Time.get_ticks_msec() - time_created > 2000:
		queue_free()
