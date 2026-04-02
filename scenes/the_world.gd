extends Node2D

const MAX_LOADED_CHUNKS = 10

var death_height: int = Constants.CHUNK_HEIGHT

var player_reference: PlayerCharacter = null

#<<<<<<< HEAD
var chunk_name_list: Array[String] = ["default", "chunk_1", "chunk_2", "chunk_3", "chunk_4", "chunk_5", "chunk_6"]

#=======
#>>>>>>> main
var score: int = 0
var score_timer: Timer
var score_timer_interval: float = 0.5
var game_over_screen: PackedScene = preload("res://scenes/game_over_screen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_reference = get_node("PlayerCharacter")
	ChunkManager.player_reference = player_reference
	ChunkManager.tile_map_layer = get_node("TileMapLayer")
	GlobalSignals.award_score.connect(add_score)
	
	score_timer = Timer.new()
	score_timer.wait_time = score_timer_interval
	score_timer.autostart = true
	score_timer.timeout.connect(add_score)
	add_child(score_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player_reference.velocity.x == 0 or player_reference.position.y >= death_height:
		game_over()


func add_score(amount: int = 1) -> void:
	score += amount
	@warning_ignore("integer_division")
	player_reference.added_speed = int(score)
	update_score()


func update_score() -> void:
	var score_label: Label = $Camera2D/UI/ScoreIndicator
	score_label.text = "Score: " + str(score)


func game_over() -> void:
	ChunkManager.reset()
	var game_over_instance: GameOverScreen = game_over_screen.instantiate()
	game_over_instance.score = score
	get_tree().get_root().add_child(game_over_instance)
	get_tree().current_scene.queue_free()
