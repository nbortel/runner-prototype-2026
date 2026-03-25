@tool
extends Node2D

@export var chunk_name: String
@export_tool_button("Save Chunk") var save_chunk_button: Callable = save_chunk
@export_tool_button("Load Chunk") var load_chunk_button: Callable = load_chunk
@export_tool_button("Clear Chunk") var clear_chunk_button: Callable = clear_chunk


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


func load_chunk() -> void:
	clear_chunk()
	var file_path: String = "res://chunks/" + chunk_name + ".json"
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var json: JSON = JSON.new()
	var json_string: String = file.get_line()
	var error: Error = json.parse(json_string)
	if error == OK:
		var data_received: Variant = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			# Load entities
			var entity_node: Node = data_received["entities"]
			var entities: Node2D = $Entities
			for entity in entities.get_children():
				entities.add_child(entity)
			add_child(entity_node)
			# Load tile map data
			var tile_map: TileMapLayer = get_node("TileMapLayer")
			var cells: Dictionary = data_received["map_data"]
			for cell: Vector2i in cells:
				var source_id: int = cells[cell][0]
				var atlas_coordinate: Vector2i = cells[cell][1]
				tile_map.set_cell(cell,source_id, atlas_coordinate)
		else:
			print("unexpected data in JSON")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())


func clear_chunk() -> void:
	var tile_map: TileMapLayer = $TileMapLayer
	var entities: Node2D = $Entities
	tile_map.clear()
	for entity in entities.get_children():
		entities.remove_child(entity)
		entity.queue_free()


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
