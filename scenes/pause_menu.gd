extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and visible:
		hide()
		get_tree().paused = false
	if get_tree().paused:
		show()
