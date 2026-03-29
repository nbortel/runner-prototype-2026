class_name Chunk
extends Node2D

static var tile_size: int = Constants.TILE_SIZE

var chunk_id: int
var tile_data: Dictionary
var position_tile: Vector2i:
	get:
		return Vector2i(int(position.x / tile_size), int(position.y / tile_size))
	set(value):
		@warning_ignore("integer_division")
		position = Vector2i(int(value.x / tile_size), int(value.y / tile_size))
var size: Rect2i
var entities: Node2D
var tile_map_layer: TileMapLayer


func _ready() -> void:
	draw_tiles()


func _init(
	initial_entities: Node2D, initial_tile_data: Dictionary,
	initial_chunk_id: int, initial_tile_map_layer: TileMapLayer
	) -> void:
	self.entities = initial_entities
	self.tile_data = initial_tile_data
	self.chunk_id = initial_chunk_id
	self.tile_map_layer = initial_tile_map_layer


func draw_tiles() -> void:
	for tile: String in tile_data:
		var tile_vector: Vector2i = HelperFunctions.string_to_vector2i(tile)
		if tile_vector:
			tile_vector += position_tile
			var source_id: int = tile_data[tile][0]
			var coord_as_string: String = tile_data[tile][1]
			var atlas_coordinate: Vector2i = HelperFunctions.string_to_vector2i(coord_as_string)
			tile_map_layer.set_cell(tile_vector, source_id, atlas_coordinate)
