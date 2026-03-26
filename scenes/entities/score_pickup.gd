extends Area2D

var score_value: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", _on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		GlobalSignals.award_score.emit(score_value)
		queue_free()
