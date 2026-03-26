extends Camera2D

@export var target_node: Node2D = null

const OFFSET_X: int = -125
const OFFSET_Y: int = -200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target_node != null:
		position.x = target_node.position.x + OFFSET_X
		#position.y = target_node.position.y + OFFSET_Y
