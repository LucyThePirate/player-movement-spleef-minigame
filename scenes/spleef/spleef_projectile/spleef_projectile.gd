extends CharacterBody2D

const GRAVITY_SCALE = 0.1
const DELTA_SCALE = 0.5
@export var power := 10.0
@export var thrown_direction := 1


func _ready() -> void:
	velocity.x += power * thrown_direction
	velocity.y -= power * 1.5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	delta *= DELTA_SCALE
	velocity += get_gravity() * GRAVITY_SCALE * delta
	var collision = move_and_collide(velocity) as KinematicCollision2D
	if collision:
		if collision.get_collider().has_method("on_hit_by_projectile"):
			collision.get_collider().on_hit_by_projectile(thrown_direction, power)
		queue_free()
