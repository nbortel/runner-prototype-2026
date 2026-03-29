class_name Chunk
extends Node2D
## The Chunk node contains all information needed to save a single area of the game map to be packed
## and loaded in elsewhere as needed. 

static var tile_size: int = Constants.TILE_SIZE

var chunk_id: int
@export var tile_data: Dictionary
var position_tile: Vector2i:
	get:
		return Vector2i(int(position.x / tile_size), int(position.y / tile_size))
	set(value):
		@warning_ignore("integer_division")
		position = Vector2i(int(value.x / tile_size), int(value.y / tile_size))
var size: Rect2i
