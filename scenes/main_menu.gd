extends Control

var button_list: Array[Label] = []
var current_selection: Label
var current_selection_index: int = 0

var the_world: PackedScene = preload("res://scenes/the_world.tscn")

func _ready() -> void:
	button_list = [
	$VBoxContainer/StartGameButton/StartGameIndicator,
	$VBoxContainer/ExitGameButton/ExitGameIndicator
	]
	current_selection = button_list[current_selection_index]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for button in button_list:
		if current_selection == button:
			button.visible = true
		else:
			button.visible = false
	if Input.is_action_just_pressed("ui_up"):
		if current_selection_index > 0:
			current_selection_index -= 1
			current_selection = button_list[current_selection_index]
	elif Input.is_action_just_pressed("ui_down"):
		if current_selection_index < len(button_list) - 1:
			current_selection_index += 1
			current_selection = button_list[current_selection_index]
	elif Input.is_action_just_pressed("ui_accept"):
		match current_selection.name:
			"StartGameIndicator":
				get_tree().change_scene_to_packed(the_world)
			"ExitGameIndicator":
				get_tree().quit()
		queue_free()
