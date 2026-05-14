extends CharacterBody2D

class_name SpleefProjectile

const GRAVITY = 98.1
const DELTA_SCALE = 0.05
@export var initial_velocity := 10.0
@export var thrown_direction := 1
var bounces := 0
const MAX_BOUNCES = 5



func _ready() -> void:
	velocity.x += initial_velocity * thrown_direction
	velocity.y -= initial_velocity * 1.5
	
	#_set_projectile_preview_on(true)

func _physics_process(delta: float) -> void:
	if not visible:
		return
	var collision = _calculate_physics_on_object(self, delta)
	if collision:
		var collision_body = collision.get_collider()
		if collision_body.has_method("on_hit_by_projectile"):
			collision_body.on_hit_by_projectile(thrown_direction, initial_velocity)
			%ImpactSFX.play()
			hide()
			await %ImpactSFX.finished
			queue_free()
		elif collision_body is TileMapLayer:
			%BounceSFX.pitch_scale = clampf(velocity.length() / 10.0, 0.5, 3)
			%BounceSFX.play()
			%BounceSFX.volume_db - 0.5
			bounces += 1
			velocity = velocity.bounce(collision.get_normal())
			if bounces >= MAX_BOUNCES:
				%ImpactSFX.play()
				hide()
				await %ImpactSFX.finished
				queue_free()



func _calculate_physics_on_object(object : CharacterBody2D, delta: float) -> KinematicCollision2D:
	# Add the gravity.
	delta *= DELTA_SCALE
	object.velocity += get_gravity() * delta
	var collision = object.move_and_collide(velocity) as KinematicCollision2D
	return collision
		
			
func _on_fallen_out_of_bounds() -> void:
	queue_free()
