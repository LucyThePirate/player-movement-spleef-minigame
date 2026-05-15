extends StaticBody2D

class_name IceBlock
@export var ice_rubble_scene : PackedScene

const TOUCH_MELTING_SPEED_MODIFIER = 3.0
const PROJECTILE_MELTING_SPEED_MODIFIER = 2.0

var max_health := 10.0
var health := max_health
@onready var base_y_scale = %Sprite2D.scale.y

func on_hit_by_projectile(thrown_direction, initial_velocity):
	health -= initial_velocity * PROJECTILE_MELTING_SPEED_MODIFIER
	%IceMeltingSFX.play()
	_update_health()

func on_player_touched_ice(delta):
	health -= delta * TOUCH_MELTING_SPEED_MODIFIER
	if not %MeltParticles.emitting:
		%IceMeltingSFX.play()
		%MeltParticles.restart()
	_update_health()
	
func _update_health():
	%Sprite2D.scale.y = base_y_scale * (health / max_health)
	if health <= 0.5 and visible:
		hide()
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, false)
		for i in range(randi_range(1, 3)):
			var new_ice_rubble = ice_rubble_scene.instantiate()
			new_ice_rubble.global_position = global_position
			get_tree().current_scene.add_child(new_ice_rubble)
		%IceBreakSFX.play()
		await %IceBreakSFX.finished
		queue_free()

		
