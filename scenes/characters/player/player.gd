class_name Player
extends Character

const ACCELERATION = 40
const DECELERATION = 50
const JUMP_GRAVITY = 850
const FALL_GRAVITY = 1000
const VARIABLE_JUMP_MULTIPLIER = 0.8
const JUMP_BUFFER_TIME = 0.1
const COYOTE_BUFFER_TIME = 0.15
const ROLL_COOLDOWN = 0.2

#signals
signal health_changed  #when player receives dmg this is a signal to the health ui script so it changes health bar ui
signal died

@onready var states = $StateMachine
@onready var marker = $Marker2D
@onready var collision_shape_default = $CollisionShape2D
@onready var collision_shape_low = $CollisionShapeLow
@onready var ammo_count: Label = $ammo_count

#audios
@onready var audio_shoot = $AudioShoot
@onready var audio_land = $AudioLand
@onready var audio_walking = $AudioWalking
@onready var audio_roll = $AudioRoll

#Raycasts
@onready var crouch_raycast_left = $Raycasts/CrouchRaycastLeft
@onready var crouch_raycast_right = $Raycasts/CrouchRaycastRight

#Timers
@onready var jump_buffer_timer: Timer = $Timers/JumpBuffer
@onready var coyote_buffer_timer: Timer = $Timers/CoyoteBuffer
@onready var cooldown_timer: Timer = $Timers/Cooldown
@onready var reload_timer: Timer = $Timers/Reload
@onready var roll_cooldown_timer: Timer = $Timers/RollCooldown

#Bulletvariables
var bullet_path = preload("res://scenes/objects/bullet.tscn")
var cooleddown = true
var bullet_speed = 400
var bullet_damage = 50
var max_ammo = 5
var ammo = 0
var cooldown = 0.5
var reload_time = 4
var reloading = false

#Input
var key_up = false
var key_down = false
var key_left = false
var key_right = false
var key_jump = false
var key_jump_pressed = false
var key_shoot_pressed = false
var key_reload_pressed = false
var key_crouch = false
var key_roll = false

var input_horizontal: float
var movement_input := Vector2.ZERO
var jump_input_released := false
var jump_input_actuation := false
var move_direction_x = 0
var facing = 1
var max_jumps = 1
var jumps = 0
var crouch_speed = 80.0

var current_state = null
var previous_state = null

var ondrone = false
var prev_vely


func _ready():
	super._ready()
	$Camera2D.make_current()
	for state in states.get_children():
		state.states = states
		state.player = self
	previous_state = states.idle
	current_state = states.idle
	audio_walking.volume_db = -20
	audio_roll.volume_db = -15


func _physics_process(delta):
	prev_vely = velocity.y
	var was_on_floor = is_on_floor()
	get_input_states()
	current_state.update(delta)
	move_and_slide()
	if was_on_floor and is_on_floor():
		coyote_buffer_timer.start(COYOTE_BUFFER_TIME)
	ammo_count.text = str(ammo)


func _process(_delta):
	if key_shoot_pressed:
		shoot()
	if key_reload_pressed:
		reload_timer.start(reload_time)
		reloading = true
	if ammo <= 0 and reloading == false:
		reloading = true
		reload_timer.start(reload_time)


func apply_gravity(delta, gravity: float = JUMP_GRAVITY):
	if not is_on_floor():
		velocity.y += gravity * delta


func get_input_states():
	key_left = Input.is_action_pressed("move_left")
	key_right = Input.is_action_pressed("move_right")
	key_jump = Input.is_action_pressed("jump")
	key_jump_pressed = Input.is_action_just_pressed("jump")
	key_shoot_pressed = Input.is_action_pressed("shoot")
	key_reload_pressed = Input.is_action_pressed("reload")

	key_crouch = Input.is_action_pressed("crouch")
	key_roll = Input.is_action_just_pressed("roll")

	if key_left:
		facing = -1
	if key_right:
		facing = 1
	anim.flip_h = (facing < 0)


func horizontal_movement(acceleration: float = ACCELERATION, deceleration: float = DECELERATION):
	move_direction_x = Input.get_axis("move_left", "move_right")
	var speed = crouch_speed if key_crouch else move_speed
	if move_direction_x != 0:
		velocity.x = move_toward(velocity.x, move_direction_x * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, move_direction_x * speed, deceleration)
	if anim.animation == "walking":
		if not audio_walking.playing:
			audio_walking.play()
			print(true)


func handle_falling():
	if !is_on_floor():
		change_state(states.fall)


func handle_landing():
	if is_on_floor():
		audio_land.volume_db = -30
		audio_land.play()
		change_state(states.idle)


func handle_jump(override_state: bool = true):
	var wants_to_jump = key_jump_pressed or jump_buffer_timer.time_left > 0
	var can_still_jump = jumps < max_jumps
	var is_jump_allowed = coyote_buffer_timer.time_left > 0 or is_on_floor()

	if wants_to_jump and can_still_jump and is_jump_allowed:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer.stop()

		if override_state:
			change_state(states.jump)


func handle_jump_buffer():
	if key_jump_pressed:
		jump_buffer_timer.start(JUMP_BUFFER_TIME)


func handle_crouching():
	if is_on_floor() and key_crouch:
		change_state(states.crouch)


func handle_roll():
	if key_roll and roll_cooldown_timer.is_stopped():
		audio_roll.play()
		change_state(states.roll)


func change_state(next_state):
	if next_state != null:
		previous_state = current_state
		current_state = next_state
		previous_state.exit()
		current_state.enter()


func take_damage(amount):
	#hit_effect()
	super.take_damage(amount)


#func hit_effect():
#$AnimatedSprite2D.material.set_shader_parameter("active", true)
#$AnimatedSprite2D.material.set_shader_parameter("active", false)
func die():
	emit_signal("died")
	call_deferred("_deferred_die")


func _deferred_die():
	super.die()


func _on_child_entered_tree(node: Node) -> void:
	print("test")
	pass  # Replace with function body.


func set_collision_to_low():
	collision_shape_default.disabled = true
	collision_shape_low.disabled = false


func set_collision_to_default():
	collision_shape_default.disabled = false
	collision_shape_low.disabled = true


func can_stand_up() -> bool:
	var is_colliding = crouch_raycast_left.is_colliding() or crouch_raycast_right.is_colliding()
	return not is_colliding


func shoot():
	if cooleddown and not reloading:
		var bullet = bullet_path.instantiate()
		bullet.global_position = marker.global_position
		bullet.speed = bullet_speed
		bullet.damage = bullet_damage
		bullet.scale *= 2
		var angle = (get_global_mouse_position() - marker.global_position).normalized()
		bullet.look_at(get_global_mouse_position())
		bullet.x_angle = angle[0]
		bullet.y_angle = angle[1]
		get_parent().add_child(bullet)
		ammo -= 1
		cooleddown = false
		audio_shoot.pitch_scale = randf_range(1.2, 1.4)
		audio_shoot.play()
		cooldown_timer.start(cooldown)


func _on_cooldown_timeout():
	cooleddown = true


func _on_reload_timeout():
	reloading = false
	ammo = max_ammo
