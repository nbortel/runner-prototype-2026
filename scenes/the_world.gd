extends Node2D

const CHUNK_WIDTH: int = 480
const TILE_SIZE: int = 16
const MAX_LOADED_CHUNKS = 10
var chunk_queue: Array[Node] = []
var next_chunk_id: int = 0
var player_reference: CharacterBody2D = null

var chunk_name_list: Array[String] = ["chunk_1", "chunk_2", "chunk_3"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_reference = get_node("PlayerCharacter")
	add_chunk()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var last_chunk: Node2D = chunk_queue[-1]
	if player_reference.position.distance_to(last_chunk.position) < 2 * CHUNK_WIDTH:
		var chunk_name: String = chunk_name_list[randi_range(0, len(chunk_name_list) - 1)]
		add_chunk(chunk_name)


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


class Chunk:
	extends Node2D
	var entities: Node
	var tile_data: Dictionary
	var chunk_id: int
	var tile_position: Vector2i:
		get():
			return self.position / TILE_SIZE
		set(value):
			self.position = value * TILE_SIZE
	var tile_map_layer: TileMapLayer
	
	@warning_ignore("shadowed_variable")
	func _init(entities: Node2D, tile_data: Dictionary, chunk_id: int, tile_map_layer: TileMapLayer) -> void:
		self.entities = entities
		add_child(entities)
		self.tile_data = tile_data
		self.chunk_id = chunk_id
		self.tile_map_layer = tile_map_layer
	
	
	func _ready() -> void:
		draw_tiles()
	
	
	func draw_tiles() -> void:
		for tile: String in tile_data:
			var tile_vector: Vector2i = HelperFunctions.string_to_vector2i(tile)
			if tile_vector:
				tile_vector += tile_position
				var source_id: int = tile_data[tile][0]
				var coord_as_string: String = tile_data[tile][1]
				var atlas_coordinate: Vector2i = HelperFunctions.string_to_vector2i(coord_as_string)
				tile_map_layer.set_cell(tile_vector, source_id, atlas_coordinate)
	
	
