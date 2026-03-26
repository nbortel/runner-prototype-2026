class_name GameOverScreen
extends Control

var label: Label
var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label = $CenterContainer/Label
	label.text += str(score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var scene: PackedScene = load("res://scenes/main_menu.tscn")
		get_tree().get_root().add_child(scene.instantiate())
		queue_free()
