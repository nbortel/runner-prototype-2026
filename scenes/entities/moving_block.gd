extends Path2D

@export var follow_speed: float = 40.0

var direction: bool = true


func _physics_process(delta: float) -> void:
	var follow: PathFollow2D = $PathFollow2D
	
	# Switch direction if end of path reached
	if follow.progress_ratio == 1.0:
		direction = !direction
	elif follow.progress_ratio == 0.0:
		direction = !direction
	
	if direction:
		follow.progress += follow_speed * delta
	else:
		follow.progress -= follow_speed * delta
