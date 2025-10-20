class_name Missile
extends Area2D

const SPRITE_DEFAULT_ANGLE = -PI / 2
@export var speed: float = 100.0
@export var explosion_scene: PackedScene
@export var turn_rate: float = 5.0
@export var lifetime: float = 5.0
@export var damage: float = 160
@export var explosion_radius: float = 64

var velocity: Vector2
var target: Node2D = null

@onready var explosion_area: Area2D = $ExplosionArea
@onready var explosion_shape: CollisionShape2D = $ExplosionArea/CollisionShape2D


func _ready() -> void:
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

	explosion_shape.shape.radius = explosion_radius


func _physics_process(delta: float) -> void:
	if target and is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		var angle_diff = dir.angle_to(velocity.normalized())
		velocity = velocity.rotated(-angle_diff * turn_rate * delta)

	if velocity.length() > 0.1:
		$Sprite2D.rotation = velocity.angle() + SPRITE_DEFAULT_ANGLE

	global_position += velocity * delta


func launch(direction: Vector2, _target: Node2D = null) -> void:
	velocity = direction.normalized() * speed
	rotation = velocity.angle()
	target = _target


func _on_body_entered(_body: Node) -> void:
	explode()
	queue_free()


func explode() -> void:
	var bodies = explosion_area.get_overlapping_bodies()
	print(bodies)
	for b in bodies:
		if b.has_method("take_damage"):
			var space = get_world_2d().direct_space_state
			var params = PhysicsRayQueryParameters2D.create(global_position, b.global_position)
			params.collide_with_areas = false
			params.collision_mask = 1 << 2

			var result = space.intersect_ray(params)

			if result and result.collider != b:
				print("explosion blocked by wall for ", b)
				continue

			var dist = global_position.distance_to(b.global_position)
			var dmg = damage * (1.0 - clamp(dist / explosion_shape.shape.radius, 0.0, 1.0))
			if dmg > 0:
				print("explosion damaged ", b, " for ", dmg)
				b.take_damage(dmg)

	var particle: CPUParticles2D = explosion_scene.instantiate()
	particle.global_position = global_position
	particle.emitting = true
	get_tree().current_scene.add_child(particle)

	queue_free()
