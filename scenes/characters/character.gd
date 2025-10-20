class_name Character
extends CharacterBody2D

#Health
@export var max_hp: int = 100
var current_hp: int = max_hp
@export var damage: int = 10

#Movement
@export var move_speed = 130.0
@export var JUMP_VELOCITY = -350.0

@onready var anim = $AnimatedSprite2D

var is_immune: bool = false


func _ready():
	if $AnimatedSprite2D != null:
		$AnimatedSprite2D.material.set_shader_parameter("active", false)


func take_damage(amount):
	if not is_immune:
		hit_effect()
		current_hp = clampi(current_hp - amount, 0, max_hp)
		if current_hp == 0:
			call_deferred("die")


func hit_effect():
	if $AnimatedSprite2D != null:
		$AnimatedSprite2D.material.set_shader_parameter("active", true)
		await get_tree().create_timer(0.15).timeout
		$AnimatedSprite2D.material.set_shader_parameter("active", false)


func die():
	get_tree().reload_current_scene()
