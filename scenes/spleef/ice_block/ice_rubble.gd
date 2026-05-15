extends CharacterBody2D

var rotational_force := 0.0
var bounces := 3

func _ready() -> void:
	bounces = randi_range(0, 3)
	rotation = randf_range(-360, 360)
	rotational_force = randf_range(-35, 35)
	velocity.y = randf_range(-1, -4)
	velocity.x = randf_range(-2, 2)
	
func _physics_process(delta: float) -> void:
	delta *= 0.05
	rotation += rotational_force * delta
	velocity += get_gravity() * delta * 0.3
	var collision = move_and_collide(velocity)
	if collision:
		if not %IceRubbleBreakSFX.playing:
			%IceRubbleBreakSFX.play()
		if bounces <= 0:
			hide()
			set_collision_mask_value(1, false)
			if %IceRubbleBreakSFX.playing:
				await %IceRubbleBreakSFX.finished
			queue_free()
		else:
			bounces -= 1
			rotation = randf_range(-360, 360)
			velocity.x += randf_range(-2, 2)
			velocity = velocity.bounce(collision.get_normal()) * 0.5
			%IceRubbleBreakSFX.volume_db -= 1.5
			%IceRubbleBreakSFX.pitch_scale += 0.3
			%Sprite2D.scale *= 0.8
