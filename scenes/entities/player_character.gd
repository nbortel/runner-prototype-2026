class_name PlayerCharacter
extends CharacterBody2D


@export var x_acceleration: float  = 30
@export var base_speed: float = 350
@export var jump_velocity: float = -400
@export var gravity_delay_time: float = 0.25
var current_gravity_delay: float = 0.0

var override_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	velocity.x = x_acceleration

func _physics_process(delta: float) -> void:
	# Check for game pause
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		return
	
	if override_vector != Vector2.ZERO:
		velocity = override_vector
		move_and_slide()
		return

	# Handle y movement
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_velocity
		current_gravity_delay = gravity_delay_time
	if not is_on_floor():
		if Input.is_action_pressed("jump") and current_gravity_delay > 0.0:
			current_gravity_delay = move_toward(current_gravity_delay, 0.0, delta)
		else:
			velocity += get_gravity() * delta
	
	# Handle x movement
	velocity.x = move_toward(velocity.x, base_speed, x_acceleration * delta)
	
	move_and_slide()
