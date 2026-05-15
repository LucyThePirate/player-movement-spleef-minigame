extends StaticBody2D

class_name IceBlock

const TOUCH_MELTING_SPEED_MODIFIER = 3.0
const PROJECTILE_MELTING_SPEED_MODIFIER = 2.0

var max_health := 10.0
var health := max_health
@onready var base_y_scale = %Sprite2D.scale.y

func on_hit_by_projectile(thrown_direction, initial_velocity):
	health -= initial_velocity * PROJECTILE_MELTING_SPEED_MODIFIER
	_update_health()

func on_player_touched_ice(delta):
	health -= delta * TOUCH_MELTING_SPEED_MODIFIER
	_update_health()
	
func _update_health():
	%Sprite2D.scale.y = base_y_scale * (health / max_health)
	if health <= 0:
		queue_free()
