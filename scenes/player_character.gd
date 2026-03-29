class_name PlayerCharacter
extends CharacterBody2D

@export var gravity_on: bool = true
@export var acceleration: int  = 30
@export var fast_fall_acceleration: int = 250
@export var base_speed: int = 350
@export var added_speed: int = 0
@export var forward_speed_modifier: int = 50
@export var backward_speed_modifier: int = 50
@export var jump_velocity: int = -500



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and gravity_on:
		if not(Input.is_action_pressed("jump")) and velocity.y < 0:
			velocity.y = 0
		velocity += get_gravity() * delta
		# Check fast-fall input
		if Input.is_action_pressed("move_down"):
			velocity.y = move_toward(velocity.y, -jump_velocity, fast_fall_acceleration * delta)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Handle Horizontal Movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction == 1:
		velocity.x = move_toward(velocity.x, base_speed + added_speed + (forward_speed_modifier + added_speed) , acceleration * delta) 
	elif direction == -1:
		velocity.x = move_toward(velocity.x, base_speed + added_speed - (backward_speed_modifier + added_speed), acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, base_speed, acceleration * delta)
	move_and_slide()
