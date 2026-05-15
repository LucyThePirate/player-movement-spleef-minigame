extends CharacterBody2D

class_name SpleefPlayer

const SPEED = 150.0
const JUMP_VELOCITY = 300.5
const GRAVITY_SCALE = 1.5
const SLOW_FALL_GRAVITY_MODIFIER = 0.5
const PROJECTILE_CHARGING_SPEED = 10.0

@export var player_num := 1
@export var projectile_scene : PackedScene

enum States {IDLE, STUNNED}
var state := States.IDLE
var invulnerable := true
var charging_time := 0.0

func _ready() -> void:
	_idle_ready()

func _idle_ready() -> void:
	state = States.IDLE
	invulnerable = true
	%AnimationPlayer.play("invulnerability_flashing")
	%InvincibilityTimer.start()
	%Sprite2D.flip_v = false
	
func _stunned_ready() -> void:
	state = States.STUNNED
	invulnerable = true
	charging_time = 0.0
	%ProgressBar.value = charging_time
	
	%StunnedSFX.play()
	%StunnedTimer.start()
	%Sprite2D.flip_v = true
	
func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			_idle_process(delta)
		States.STUNNED:
			_stunned_process(delta)
	
func _idle_process(delta: float) -> void:
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
		%JumpSFX.play()
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_axis("move_left%s" % player_num, "move_right%s" % player_num)
	if input_dir:
		velocity.x = input_dir * SPEED
		%Sprite2D.flip_h = input_dir > 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	_check_for_touching_ice(delta)
	
	# Handle charging a projectile
	if Input.is_action_pressed("action%s" % player_num):
		charging_time += delta * PROJECTILE_CHARGING_SPEED
		if not %ChargeSFX.playing:
			%ChargeSFX.pitch_scale = clampf((charging_time + 0.5) / 4.5, 0.5, 2.0)
			%ChargeSFX.play()
		%ProgressBar.value = charging_time
	
	# Handle creating and launching a projectile
	if Input.is_action_just_released("action%s" % player_num):
		_launch_projectile()
		
		
func _launch_projectile():
	%ShootSFX.pitch_scale = (charging_time + 1) / 4.5
	%ShootSFX.play()
	var new_projectile := projectile_scene.instantiate() as CharacterBody2D
	new_projectile.add_collision_exception_with(self)
	new_projectile.global_position = global_position
	new_projectile.thrown_direction = 1 if %Sprite2D.flip_h else -1
	new_projectile.initial_velocity = 1 + min(charging_time, 9)
	charging_time = 0.0
	%ProgressBar.value = charging_time
	get_tree().current_scene.add_child(new_projectile)


func _stunned_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * GRAVITY_SCALE * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.01)
	_check_for_touching_ice(delta)

func on_hit_by_projectile(thrown_direction, power):
	if invulnerable:
		return
	if state == States.IDLE:
		velocity.x = thrown_direction * power * 15
		velocity.y -= power * 10
		_stunned_ready()

func _check_for_touching_ice(delta):
	if move_and_slide():
		var colliding_body = get_last_slide_collision().get_collider()
		if colliding_body is IceBlock:
			colliding_body.on_player_touched_ice(delta)


func _on_stunned_timer_timeout() -> void:
	if state == States.STUNNED:
		_idle_ready()


func _on_invincibility_timer_timeout() -> void:
	%AnimationPlayer.play("RESET")
	invulnerable = false


func _on_fallen_out_of_bounds() -> void:
	queue_free()
