@tool
extends Node2D

@export var chunk_name: String
@export_tool_button("Clear Chunk") var clear_chunk_button: Callable = clear_chunk
@export_tool_button("Save Chunk") var save_chunk_button: Callable = save_chunk
@export_tool_button("Load Chunk") var load_chunk_button: Callable = load_chunk



## Clear the contents of the chunk
func clear_chunk() -> void:
	var tile_map: TileMapLayer = $TileMapLayer
	var entities: Node2D = $Entities
	tile_map.clear()
	if entities:
		for entity in entities.get_children():
			entities.remove_child(entity)
			entity.queue_free()
		entities.queue_free()


## Save the current contents of the chunk
func save_chunk() -> void:
	if not chunk_name or chunk_name == "":
		print("Chunk must have name. Not saved")
		return

	save_tile_map_data()
	save_entity_data()

	trigger_rescan()
	print("saved chunk")


## Save tile data to JSON file
func save_tile_map_data() -> void:
	var tile_map_layer: TileMapLayer = $TileMapLayer
	
	var map_data: Dictionary = get_tilemap_data(tile_map_layer)
	var map_data_json_string: String = JSON.stringify(map_data)
	
	var file_path: String = "res://chunks/" + chunk_name + ".json"
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(map_data_json_string)
	file.close()


## Save entity data as PackedScene
func save_entity_data() -> void:
	var entities: Node2D = $Entities
	# Need to set owner for entities to be persisted in PackedScene
	entities.owner = self
	for entity in entities.get_children():
		entity.owner = entities
	var scene: PackedScene = PackedScene.new()
	var file_path: String = "res://chunks/" + chunk_name + ".tscn"
	var result: Error = scene.pack(entities)
	if result == OK:
		var error: Error = ResourceSaver.save(scene, file_path)
		if error != OK:
			push_error("An error occurred while saving the scene to disk")


## Load the chunk with name matching current chunk_name
func load_chunk() -> void:
	clear_chunk()
	load_chunk_tiles()
	load_chunk_entities()


## Draw tiles within the chunk to the TileMapLayer
func load_chunk_tiles() -> void:
	var file_path: String = "res://chunks/" + chunk_name + ".json"
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	
	var json: JSON = JSON.new()
	var json_string: String = file.get_line()
	
	var tile_map_layer: TileMapLayer = get_node("TileMapLayer")
	
	var error: Error = json.parse(json_string)
	if error == OK:
		var data_received: Variant = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			var cell_data: Dictionary = data_received
			# Load tile map data
			for cell: String in cell_data:
				var cell_vector: Vector2i = string_to_vector2i(cell)
				if cell_vector:
					var source_id: int = cell_data[cell][0]
					var coord_as_string: String = cell_data[cell][1]
					var atlas_coordinate: Vector2i = string_to_vector2i(coord_as_string)
					tile_map_layer.set_cell(cell_vector, source_id, atlas_coordinate)
		else:
			print("unexpected data in JSON")
	else:
		print(
			"JSON Parse Error: ", json.get_error_message(), " in ", 
			json_string, " at line ", json.get_error_line()
		)


## Instantiate entities within the chunk
func load_chunk_entities() -> void:
	var file_path: String = "res://chunks/" + chunk_name + ".tscn"
	var packed_scene: PackedScene = load(file_path)
	var packed_entities: Node = packed_scene.instantiate()
	var entities: Node2D = $Entities
	if entities:
		entities.queue_free()
	add_child(packed_entities)
	packed_entities.name = "Entities"
	packed_entities.owner = get_tree().edited_scene_root
	set_editable_instance(packed_entities, true)


## Trigger a rescan of the FileSystem 
func trigger_rescan() -> void:
	if Engine.is_editor_hint():
		var file_system: EditorFileSystem = EditorInterface.get_resource_filesystem()
		if not file_system.is_scanning():
			file_system.scan()


## Read the contents of the TileMapLayer to a Dictionary
func get_tilemap_data(tilemap: TileMapLayer) -> Dictionary:
	var map_data: Dictionary = {}
	var used_cells: Array[Vector2i] = tilemap.get_used_cells()
	
	for cell in used_cells:
		var source_id: int = tilemap.get_cell_source_id(cell)
		var atlas_coordinate: Vector2i = tilemap.get_cell_atlas_coords(cell)
		
		map_data[cell] = [source_id, atlas_coordinate]
	
	return map_data


static func string_to_vector2i(string := "") -> Vector2i:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: PackedStringArray = new_string.split(", ")

		return Vector2i(int(array[0]), int(array[1]))

	return Vector2i.ZERO
