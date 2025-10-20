class_name Enemy
extends Character

var target: Node2D = null
@onready var ray_cast_2d: RayCast2D = $RayCast2D

@onready var ray_cast_left_bottom: RayCast2D = $Raycasts/RaycastLeftBottom
@onready var ray_cast_right_bottom: RayCast2D = $Raycasts/RaycastRightBottom
@onready var ray_cast_left_top: RayCast2D = $Raycasts/RaycastLeftTop
@onready var ray_cast_right_top: RayCast2D = $Raycasts/RaycastRightTop
@onready var check_below_right: RayCast2D = $Raycasts/CheckBelowRight
@onready var check_below_left: RayCast2D = $Raycasts/CheckBelowLeft

@onready var player_detector: Area2D = $PlayerDetector
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var has_collided = false
var speed = 80
var patrol_speed = 50
var chase_speed = 100
var direction = Vector2.RIGHT

enum { PATROL, ATTACK, CHASE, IDLE }
var current_state = PATROL

var attack_cooldown := 0.0
var attack_delay := 1.0

var gravity = 100
var vely=0
#func _process(delta):
# 	velocity.x = speed
# 	animated_sprite_2d.flip_h = false
# 	if ray_cast_2d.is_colliding():
# 		has_collided = true
# 		enemy_animation()
# 	else:
# 		has_collided = false
# 		enemy_animation()
#
#	if not is_on_floor():
#		velocity.y += 1000 * delta


func _ready():
	player_detector.body_entered.connect(_on_player_detector_body_entered)
	player_detector.body_exited.connect(_on_player_detector_body_exited)
	damage = 50


func _physics_process(delta):
	if attack_cooldown > 0:
		attack_cooldown -= delta

	if current_state == ATTACK and animated_sprite_2d.is_playing():
		velocity = Vector2.ZERO
		return

	if target:
		var info = get_distance_to_player()
		direction = info["direction"]

		if info["distance"] <= 20.0:
			current_state = ATTACK
		elif attack_cooldown > 0:
			current_state = IDLE
		else:
			current_state = CHASE

	match current_state:
		IDLE:
			animated_sprite_2d.play("idle")
		PATROL:
			animated_sprite_2d.play("walking")
			check_wall()
			velocity = direction * speed
		CHASE:
			animated_sprite_2d.play("walking")
			velocity = direction * speed * 1.5
		ATTACK:
			velocity = Vector2.ZERO
			attack()
			attack_cooldown = attack_delay

	if direction == Vector2.RIGHT:
		animated_sprite_2d.flip_h = false
		player_detector.scale = Vector2(1, 1)
	else:
		animated_sprite_2d.flip_h = true
		player_detector.scale = Vector2(-1, 1)
	if not is_on_floor():
		vely+=gravity*delta
		velocity.y=vely
	else:vely=0
	move_and_slide()
	velocity.y=0


func enemy_animation():
	if has_collided:
		if $RayCast2D.get_collider() == CharacterBody2D:
			$AnimatedSprite2D.play("attack")
		else:
			$AnimatedSprite2D.play("idle")
			velocity.x = -speed
			animated_sprite_2d.flip_h = true
			$RayCast2D.target_position = Vector2(-18, 0)
	else:
		$AnimatedSprite2D.play("walking")


func check_wall():
	if ray_cast_left_top.is_colliding() or ray_cast_left_bottom.is_colliding() or !check_below_left.is_colliding():
		direction = Vector2.RIGHT
	elif ray_cast_right_bottom.is_colliding() or ray_cast_right_top.is_colliding() or !check_below_right.is_colliding():
		direction = Vector2.LEFT


func attack():
	if not animation_player.is_playing():
		animation_player.play("attack")
		animated_sprite_2d.play("attack")


func get_distance_to_player() -> Dictionary:
	var distance: float = global_position.distance_to(target.global_position)
	var dir_x: float = target.global_position.x - global_position.x
	var dir: Vector2 = Vector2.RIGHT if dir_x > 0 else Vector2.LEFT
	return {"distance": distance, "direction": dir}


func take_damage(amount):
	super.take_damage(amount)


func die():
	queue_free()


func _on_player_detector_body_entered(body: Node2D):
	if body is Player:
		target = body
		current_state = CHASE


func _on_player_detector_body_exited(body: Node2D):
	if body is Player:
		target = null
		current_state = PATROL


func _on_attack_area_body_entered(body):
	body.take_damage(damage)
