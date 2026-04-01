extends Node


var chunk_queue: Array[Chunk] = []
var next_chunk_id: int = 0
var chunk_name_list: Array[String] = ["default", "chunk_1", "chunk_2", "chunk_3", "chunk_4"]
var upcoming_chunks: Array[String] = []

var player_reference: PlayerCharacter = null
var tile_map_layer: TileMapLayer = null


func _ready() -> void:
	upcoming_chunks = ChunkSequences.test_sequence.duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not tile_map_layer:
		return
	if len(chunk_queue) == 0:
		add_chunk()
	var last_chunk: Chunk = chunk_queue[-1]
	if player_reference.position.distance_to(last_chunk.position) < 2 * Constants.CHUNK_WIDTH:
		var chunk_name: String
		if len(upcoming_chunks) > 0:
			chunk_name = upcoming_chunks.pop_front()
		else:
			chunk_name = chunk_name_list[randi_range(0, len(chunk_name_list) - 1)]
		add_chunk(chunk_name)


# Pop and return front chunk if max chunks exceeded
func check_chunk_count() -> Chunk:
	if len(chunk_queue) > Constants.MAX_LOADED_CHUNKS:
		return chunk_queue.pop_front()
	else:
		return null


## Spawn in a new chunk at the end of the current list
func add_chunk(chunk_name: String = "default") -> void:
	# Load entities from tscn
	var new_chunk: Chunk = load_chunk(chunk_name)
	new_chunk.chunk_id = next_chunk_id
	new_chunk.position = Vector2i(new_chunk.chunk_id * Constants.CHUNK_WIDTH, 0)
	new_chunk.name = chunk_name + "_" + str(next_chunk_id)

	HelperFunctions.draw_tiles(tile_map_layer, new_chunk.tile_data, new_chunk.position_tile)
	
	# Add chunk as child and reference to list
	get_tree().current_scene.add_child(new_chunk)
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


func reset() -> void:
	player_reference = null
	tile_map_layer = null
	chunk_queue = []
	next_chunk_id = 0
