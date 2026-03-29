extends Node2D

const CHUNK_WIDTH: int = 480
const TILE_SIZE: int = 16
const MAX_LOADED_CHUNKS = 10

var chunk_queue: Array[Node] = []
var next_chunk_id: int = 0
var player_reference: PlayerCharacter = null

var chunk_name_list: Array[String] = ["chunk_1", "chunk_2", "chunk_3"]

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
	var last_chunk: Node2D = chunk_queue[-1]
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


func add_chunk(chunk_name: String = "default") -> void:
	# Load entities from tscn
	var new_chunk_entities: Node2D = load_chunk_entities(chunk_name)
	if new_chunk_entities:
		new_chunk_entities.name = chunk_name + "_" + str(next_chunk_id) + "_entities"
	else:
		push_error("Null value for chunk entitites from " + chunk_name + "tscn")
	# Load tile data from json
	var new_chunk_tile_data: Dictionary = load_chunk_tiles(chunk_name)
	# Pass data into new chunk instance
	var tile_map_layer: TileMapLayer = get_node("TileMapLayer")
	var new_chunk: Chunk = Chunk.new(new_chunk_entities, new_chunk_tile_data, next_chunk_id, tile_map_layer)
	new_chunk.position = Vector2i(new_chunk.chunk_id * CHUNK_WIDTH, 0)
	new_chunk.name = chunk_name + "_" + str(next_chunk_id)
	# Add chunk as child and reference to list
	add_child(new_chunk)
	chunk_queue.push_back(new_chunk)
	var check_count: Chunk = check_chunk_count()
	if check_count:
		check_count.queue_free()
	next_chunk_id += 1


## Instantiate entities within the chunk
func load_chunk_entities(chunk_name: String = "default") -> Node2D:
	var file_path: String = "res://chunks/" + chunk_name + ".tscn"
	var packed_scene: PackedScene = load(file_path)
	var packed_entities: Node2D = packed_scene.instantiate()
	if typeof(packed_entities) == typeof(Node2D):
		return packed_entities
	else:
		push_error("Could not load entities from chunk: " + chunk_name + ".tscn\nWrong node type.")
		return null


## Draw tiles within the chunk to the TileMapLayer
func load_chunk_tiles(chunk_name: String) -> Dictionary:
	var file_path: String = "res://chunks/" + chunk_name + ".json"
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	
	var json: JSON = JSON.new()
	var json_string: String = file.get_line()
	
	var error: Error = json.parse(json_string)
	if error == OK:
		var data_received: Variant = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			var cell_data: Dictionary = data_received
			return cell_data
		else:
			push_error("unexpected data in JSON; cannot load tile data")
			return {}
	else:
		print(
			"JSON Parse Error: ", json.get_error_message(), " in ", 
			json_string, " at line ", json.get_error_line()
		)
		return {}


func game_over() -> void:
	var game_over_instance: GameOverScreen = game_over_screen.instantiate()
	game_over_instance.score = score
	get_tree().get_root().add_child(game_over_instance)
	get_tree().current_scene.queue_free()
