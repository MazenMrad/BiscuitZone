extends CharacterBody2D

@export var missile_scene: PackedScene
@export var stop_distance: float = 200.0
@export var attack_range: float = 150.0
@export var chase_speed: float = 60.0
@export var move_speed: float = 18
@export var cooldown: float = 3.0

@onready var player_detector: Area2D = $PlayerDetector

enum { PATROL, ATTACK, CHASE, IDLE }
enum PatrolState { MOVING, WAITING }

var current_state = PATROL
var patrol_state = PatrolState.WAITING
var target: Node2D = null
var is_player_in_range: bool = false
var direction: Vector2

var home_position: Vector2
var max_patrol_distance: float = 100
var is_patrol_waiting: bool = true

var max_hp = 100
var current_hp

func _ready():
	home_position = global_position
	player_detector.body_entered.connect(_on_player_detector_body_entered)
	player_detector.body_exited.connect(_on_player_detector_body_exited)
	current_hp = max_hp

func _physics_process(_delta):
	if target:
		var info = get_distance_to_player()
		direction = info["direction"]
		var distance_to_player = info["distance"]

		if distance_to_player < attack_range and $Cooldown.is_stopped():
			attack()

	else:
		if global_position.distance_to(home_position) > max_patrol_distance:
			direction = (home_position - global_position).normalized()

	if is_patrol_waiting:
		velocity = Vector2.ZERO
	else:
		velocity = direction * move_speed

	move_and_slide()
	move_and_slide()


func attack():
	var missile: Missile = missile_scene.instantiate()
	missile.global_position = global_position
	# var dir = (target.global_position - global_position).normalized()
	missile.launch(Vector2.DOWN, target)
	get_parent().add_child(missile)
	$Cooldown.start(cooldown)


func get_distance_to_player() -> Dictionary:
	var distance: float = global_position.distance_to(target.global_position)
	var dir_x: float = target.global_position.x - global_position.x
	var dir: Vector2 = Vector2.RIGHT if dir_x > 0 else Vector2.LEFT
	return {"distance": distance, "direction": dir}


func _on_player_detector_body_entered(body: Node2D):
	if body is Player:
		target = body
		current_state = CHASE


func _on_player_detector_body_exited(body: Node2D):
	if body is Player:
		target = null
		current_state = PATROL


func _on_patrol_timer_timeout():
	if target:
		return

	if is_patrol_waiting:
		var angle = randf_range(0, TAU)
		direction = Vector2(cos(angle), sin(angle)).normalized()
		is_patrol_waiting = false
		$PatrolTimer.start(randf_range(1.5, 3.0))
	else:
		is_patrol_waiting = true
		$PatrolTimer.start(randf_range(2, 3))


func choose(array: Array):
	array.shuffle()
	return array.front()
	
func take_damage(amount):
	current_hp-=amount
	if current_hp <=0:
		die()

func die():
	queue_free()
