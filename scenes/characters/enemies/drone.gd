class_name drone
extends CharacterBody2D

var hp = 50
var damage = 20
var SPEED = 100
var ACCELERATION = 512
var UP_ACCELERATION = 400
var UP_SPEED = 50
var ALLERT_TIME = 7
var ALARM_GROUP_TIME = 2

var direction = right
var detected = false
var too_low = false
var on_top =false
var was_detected = false
var last_position=Vector2()
var allerted = false
var ontop

var laser_cooling_down = false
var laser_active = false
var laser_dur = 1
var laser_cd = 5


@onready var right = $Right
@onready var left = $Left
@onready var down = $Down
@onready var line_of_sight = $LineOfSight
var player 
@onready var allert_timer = $AllertTimer
@onready var alarm_group_timer = $AlarmGroupTimer
@onready var laser_cooldown = $LaserCooldown
@onready var laser_duration = $LaserDuration
@onready var laser = $Laser
@onready var laser_cast = $Laser_Cast
@onready var damage_zone = $Laser_Cast/DamageZone
@onready var damage_shape = $Laser_Cast/DamageZone/CollisionShape2D

@onready var audio_laser = $AudioStreamPlayer2D
@onready var audio_alarm = $AudioAlarm
@onready var audio_allerted = $AudioAllerted


func _ready():
	laser.visible=false
	damage_zone.monitoring=false 
	damage_shape.shape.size.y = laser.width
	player = get_tree().get_nodes_in_group("player")[0]
func _physics_process(delta):
	if down.is_colliding():
		velocity.y = move_toward(velocity.y, -UP_SPEED, UP_ACCELERATION)
	else:
		velocity.y = move_toward(velocity.y,UP_SPEED/2,UP_ACCELERATION/2)
	if left.is_colliding() and right.is_colliding():
		direction=0
	elif left.is_colliding():
		direction = 1
	elif right.is_colliding():
		direction = -1 
	
	move_and_slide()
	
	

	
func _process(delta):
	var collider = laser_cast.get_collider()
	if collider:
		if collider.is_in_group("player"):
			collider.take_damage(damage*delta)
	if not laser_active:	
		laser_cast.rotation=line_of_sight.rotation
		laser.rotation = laser_cast.rotation
		
	if ontop:
		ontop.velocity.y/=2
	was_detected=detected
	if detected and player:
		alarm_group()
		allerted=false
		line_of_sight.look_at(Vector2(player.position.x,player.position.y-15))
		if not laser_cooling_down and not laser_active and not ontop:
			shoot()
		if line_of_sight.get_collider() != player:
				detected =false
		for i in line_of_sight.get_children():
			if i.get_collider() != player and detected ==false:
				detected =false
			else: 
				detected= true 
		
	elif allerted:
		line_of_sight.look_at(last_position)
		for i in line_of_sight.get_children():
			if i.get_collider() != player and detected ==false:
				detected =false
			else: detected= true
	if !detected and was_detected:
		allerted =true
		allert_timer.start(ALLERT_TIME)
		last_position = Vector2(player.position.x,player.position.y-10)
	
	if hp <=0:
		die()
	
	
	

	

func _on_detection_area_body_entered(body):
	detected = true
	line_of_sight.look_at(Vector2(player.position.x,player.position.y-15))
	if not laser_active:	
		laser_cast.rotation=line_of_sight.rotation
		laser.rotation = laser_cast.rotation
	
	
	alarm_group()


func take_damage(damage):
	hp-=damage

func die():
	get_node(".").queue_free()
	
func _on_allert_timer_timeout():
	if detected==false:
		allerted=false
	
func alarm_group():
	var enemies=get_tree().get_nodes_in_group("drone")
	for i in enemies:
		if global_position.distance_to(i.global_position)<1000:
			if i.detected==false:
				i.allerted=true
				i.allert_timer.start(i.ALLERT_TIME)
				i.last_position = Vector2(player.position.x,player.position.y-10)
	alarm_group_timer.start()


func _on_standing_area_body_entered(body):
	ontop=body
	
	if Input.is_action_just_pressed("jump"):
		body.velocity.y=-500
		print("tesqsddddddt")

func shoot():
	print("shoot")
	audio_laser.pitch_scale = randf_range(0.9,1.1)
	audio_laser.play()
	if laser_cast.is_colliding():
		var point = laser_cast.get_collision_point()-global_position
		print(point)
		var distance = Vector2(0,0).distance_to(point)
		laser.set_point_position(1, Vector2(distance,0))
		damage_shape.shape.size.x=distance
		damage_shape.position.x=distance/2
	else:
		var distance = laser_cast.target_position.x
		laser.set_point_position(1, Vector2(distance,0))
		damage_shape.shape.size.x=distance+20
		damage_shape.position.x=distance/2-10
	laser.visible = true
	laser_active = true
	laser_duration.start(laser_dur)
	damage_zone.monitoring = true
	damage_zone.visible = true
func _on_standing_area_body_exited(body):
	ontop=0


func _on_laser_duration_timeout():
	laser.visible=false
	laser_active=false
	laser_cooling_down = true
	damage_zone.monitoring=false
	damage_zone.visible=false
	laser_cooldown.start(laser_cd)
	


func _on_laser_cooldown_timeout():
	laser_cooling_down = false


func _on_damage_zone_body_entered(body):
	body.take_damage(damage)
	print(body.current_hp)
