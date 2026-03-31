extends Node2D

const CHUNK_WIDTH: int = 480
const TILE_SIZE: int = 16
const MAX_LOADED_CHUNKS = 10

var chunk_queue: Array[Chunk] = []
var next_chunk_id: int = 0
var player_reference: PlayerCharacter = null

var chunk_name_list: Array[String] = ["default", "chunk_1", "chunk_2", "chunk_3", "chunk_4", "chunk_5"]

var score: int = 0
var score_timer: Timer
var score_timer_interval: float = 0.5
var game_over_screen: PackedScene = preload("res://scenes/game_over_screen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_reference = get_node("PlayerCharacter")
	add_chunk()
	GlobalSignals.award_score.connect(add_score)
	
	score_timer = Timer.new()
	score_timer.wait_time = score_timer_interval
	score_timer.autostart = true
	score_timer.timeout.connect(add_score)
	add_child(score_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var last_chunk: Chunk = chunk_queue[-1]
	if player_reference.position.distance_to(last_chunk.position) < 2 * CHUNK_WIDTH:
		var chunk_name: String = chunk_name_list[randi_range(0, len(chunk_name_list) - 1)]
		add_chunk(chunk_name)
	if player_reference.velocity.x == 0:
		game_over()


func add_score(amount: int = 1) -> void:
	score += amount
	@warning_ignore("integer_division")
	player_reference.added_speed = int(score)
	update_score()


func update_score() -> void:
	var score_label: Label = $Camera2D/UI/ScoreIndicator
	score_label.text = "Score: " + str(score)


# Pop and return front chunk if max chunks exceeded
func check_chunk_count() -> Chunk:
	if len(chunk_queue) > MAX_LOADED_CHUNKS:
		return chunk_queue.pop_front()
	else:
		return null


## Spawn in a new chunk at the end of the current list
func add_chunk(chunk_name: String = "default") -> void:
	# Load entities from tscn
	var new_chunk: Chunk = load_chunk(chunk_name)
	new_chunk.chunk_id = next_chunk_id
	new_chunk.position = Vector2i(new_chunk.chunk_id * CHUNK_WIDTH, 0)
	new_chunk.name = chunk_name + "_" + str(next_chunk_id)
	
	var tile_map_layer: TileMapLayer = get_node("TileMapLayer")
	HelperFunctions.draw_tiles(tile_map_layer, new_chunk.tile_data, new_chunk.position_tile)
	
	# Add chunk as child and reference to list
	add_child(new_chunk)
	chunk_queue.push_back(new_chunk)
	
	var check_count: Chunk = check_chunk_count()
	if check_count:
		check_count.queue_free()
	next_chunk_id += 1


## Instantiate packed chunk
func load_chunk(chunk_name: String = "default") -> Chunk:
	var file_path: String = "res://chunks/" + chunk_name + ".tscn"
	var packed_scene: PackedScene = load(file_path)
	var loaded_chunk: Chunk = packed_scene.instantiate()
	return loaded_chunk


func game_over() -> void:
	var game_over_instance: GameOverScreen = game_over_screen.instantiate()
	game_over_instance.score = score
	get_tree().get_root().add_child(game_over_instance)
	get_tree().current_scene.queue_free()
