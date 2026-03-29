class_name HelperFunctions
extends Node
### Global helper functions. STATIC ONLY


static func string_to_vector2i(string := "") -> Vector2i:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: PackedStringArray = new_string.split(", ")

		return Vector2i(int(array[0]), int(array[1]))

	return Vector2i.ZERO


## Set a series of cells on a given TileMapLayer using Dictionary tile_data.
## tile_data should be structured: {tile_coordinate: [source_id, atlas_coordinate], ...}
## Offset allows a set of tiles to be drawn at a relative position rather than absolute
static func draw_tiles(tile_map_layer: TileMapLayer, tile_data: Dictionary, offset: Vector2i = Vector2i.ZERO) -> void:
	for tile: Vector2i in tile_data:
		var source_id: int = tile_data[tile][0]
		var atlas_coordinate: Vector2i = tile_data[tile][1]
		tile_map_layer.set_cell(tile + offset, source_id, atlas_coordinate)


## Read basic tile data to a Dictionary and return the result.
## tile_data is structured: {tile_coordinate: [source_id, atlas_coordinate], ...}
static func tile_data_to_dictionary(tile_map_layer: TileMapLayer) -> Dictionary:
	var tile_data: Dictionary = {}
	var used_cells: Array[Vector2i] = tile_map_layer.get_used_cells()
	
	for cell in used_cells:
		var source_id: int = tile_map_layer.get_cell_source_id(cell)
		var atlas_coordinate: Vector2i = tile_map_layer.get_cell_atlas_coords(cell)
		tile_data[cell] = [source_id, atlas_coordinate]
	return tile_data
