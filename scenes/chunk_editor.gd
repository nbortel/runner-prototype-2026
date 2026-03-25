@tool
extends Node2D

@export var chunk_name: String
@export_tool_button("Save Chunk") var save_chunk_button: Variant = save_chunk


func save_chunk() -> void:
	if not chunk_name or chunk_name == "":
		print("Chunk must have name. Not saved")
		return
	var tile_map_layer: TileMapLayer = $TileMapLayer
	var map_data: Dictionary = get_tilemap_data(tile_map_layer)
	
	var entities: Node2D = $Entities
	
	var data: Dictionary = {"map_data": map_data, "entities": entities}
	var json_string: String = JSON.stringify(data)
	
	var file_path: String = "res://chunks/" + chunk_name + ".json"
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(json_string)
	print("saved chunk to: " + file_path)
	file.close()
	trigger_rescan()


# Trigger a rescan of the FileSystem 
func trigger_rescan() -> void:
	if Engine.is_editor_hint():
		var file_system: EditorFileSystem = EditorInterface.get_resource_filesystem()
		if not file_system.is_scanning():
			file_system.scan()


func get_tilemap_data(tilemap: TileMapLayer) -> Dictionary:
	var map_data: Dictionary = {}
	var used_cells: Array[Vector2i] = tilemap.get_used_cells()
	
	for cell in used_cells:
		var source_id: int = tilemap.get_cell_source_id(cell)
		var atlas_coordinate: Vector2i = tilemap.get_cell_atlas_coords(cell)
		
		map_data[cell] = [source_id, atlas_coordinate]
	
	return map_data
