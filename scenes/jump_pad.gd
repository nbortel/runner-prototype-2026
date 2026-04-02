extends Area2D

@export var desired_tile_height: int = 0

var triggered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", _on_body_entered)

 
func _on_body_entered(body: Object) -> void:
	if body is PlayerCharacter and not triggered:
		var player: PlayerCharacter = body
		player.override_vector = get_required_impulse(player)
		triggered = true


func get_required_impulse(body: PlayerCharacter) -> Vector2:
	var desired_height: float = desired_tile_height * Constants.TILE_SIZE
	var gravity_y: float = body.get_gravity().y
	var required_impulse_y: float = - sqrt(2 * gravity_y * desired_height)
	return Vector2(body.base_speed, required_impulse_y)
