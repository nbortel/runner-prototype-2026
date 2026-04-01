extends Area2D

@export var apex: Marker2D

var triggered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", _on_body_entered)

 
func _on_body_entered(body: Object) -> void:
	if body is PlayerCharacter and not triggered:
		var player: PlayerCharacter = body
		triggered = true


func get_required_impulse(character: PlayerCharacter) -> Vector2:
	return Vector2.ZERO
