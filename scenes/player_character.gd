class_name PlayerCharacter
extends CharacterBody2D

const VELOCITY_DELTA = 3.0
const BASE_SPEED: int = 100.0
const FORWARD_SPEED_MODIFIER = 25.0
const BACKWARD_SPEED_MODIFIER = 25.0

const JUMP_VELOCITY = -400.0

@export var gravity_on: bool = true


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and gravity_on:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Horizontal Movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction == 1:
		velocity.x = move_toward(velocity.x, BASE_SPEED + FORWARD_SPEED_MODIFIER, VELOCITY_DELTA)
	elif direction == -1:
		velocity.x = move_toward(velocity.x, BASE_SPEED - BACKWARD_SPEED_MODIFIER, VELOCITY_DELTA)
	else:
		velocity.x = move_toward(velocity.x, BASE_SPEED, VELOCITY_DELTA)
	move_and_slide()
