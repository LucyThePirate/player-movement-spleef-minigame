extends CharacterBody2D

const SPEED = 175.0
const JUMP_VELOCITY = 300.5
const GRAVITY_SCALE = 1.5
const SLOW_FALL_GRAVITY_MODIFIER = 0.5

@export var player_num := 1
@export var projectile_scene : PackedScene

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("jump%s" % player_num):
			velocity += get_gravity() * GRAVITY_SCALE * SLOW_FALL_GRAVITY_MODIFIER * delta
		else:	
			velocity += get_gravity() * GRAVITY_SCALE * delta
	move_and_slide()

	# Handle jump.
	if Input.is_action_just_pressed("jump%s" % player_num) and is_on_floor():
		velocity.y = -JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_axis("move_left%s" % player_num, "move_right%s" % player_num)
	if input_dir:
		velocity.x = input_dir * SPEED
		%Sprite2D.flip_h = input_dir > 0
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	if Input.is_action_just_pressed("action%s" % player_num):
		var new_projectile := projectile_scene.instantiate() as CharacterBody2D
		new_projectile.add_collision_exception_with(self)
		new_projectile.global_position = global_position
		new_projectile.thrown_direction = 1 if %Sprite2D.flip_h else -1
		get_tree().current_scene.add_child(new_projectile)

func on_hit_by_projectile(thrown_direction, power):
	velocity.x += thrown_direction * power * 10
	velocity.y -= power * 10
