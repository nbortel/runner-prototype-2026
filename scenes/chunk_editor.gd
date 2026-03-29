@tool
extends Node2D

@export_tool_button("Clear Editor") var clear_editor_button: Callable = clear_editor
@export_group("Save Chunk")
@export var chunk: Chunk
@export_tool_button("Save Chunk") var save_chunk_button: Callable = save_chunk
@export_group("Load Chunk")
@export_file("*.tscn") var chunk_to_load: String
@export_tool_button("Load") var load_chunk_button: Callable = load_chunk


## Clear the editor of all chunks and wipe tile map
func clear_editor() -> void:
	var tile_map: TileMapLayer = $TileMapLayer
	tile_map.clear()
	var children: Array[Node] = get_children()
	for child in children:
		if child is Chunk:
			child.queue_free()


## Save the contents of the chunk to a packed scene to be loaded elsewhere
func save_chunk() -> void:
	if chunk:
		save_tile_map_data()
		set_owner_chunk_entities()
		pack_chunk()
		trigger_rescan()
	else:
		push_error("Must select a chunk to be saved")


## Store tile data in the currently selected chunk
func save_tile_map_data() -> void:
	var tile_map_layer: TileMapLayer = get_node("TileMapLayer")
	chunk.tile_data = HelperFunctions.tile_data_to_dictionary(tile_map_layer)


## Set chunk to owner of all children. Must be done before packing
func set_owner_chunk_entities() -> void:
	var entities: Array[Node] = chunk.get_children()
	for entity in entities:
		entity.owner = chunk


## Pack chunk to PackedScene
func pack_chunk() -> void:
	var scene: PackedScene = PackedScene.new()
	var file_path: String = "res://chunks/" + chunk.name.to_lower() + ".tscn"
	var result: Error = scene.pack(chunk)
	if result == OK:
		var error: Error = ResourceSaver.save(scene, file_path)
		if error != OK:
			push_error("An error occurred while saving chunk to disk")


## Load the chunk with name matching current chunk_name
func load_chunk() -> void:
	clear_editor()
	var file_path: String = chunk_to_load
	var packed_chunk: PackedScene = load(file_path)
	var new_chunk: Chunk = packed_chunk.instantiate()
	add_child(new_chunk)
	new_chunk.owner = self
	set_editable_instance(new_chunk, true)
	load_chunk_tiles(new_chunk)


## Draw tiles within the chunk to the TileMapLayer
func load_chunk_tiles(new_chunk: Chunk) -> void:
	var tile_map_layer: TileMapLayer = get_node("TileMapLayer")
	var tile_data_dictionary: Dictionary = new_chunk.tile_data
	HelperFunctions.draw_tiles(tile_map_layer, tile_data_dictionary)


## Trigger a rescan of the FileSystem 
func trigger_rescan() -> void:
	if Engine.is_editor_hint():
		var file_system: EditorFileSystem = EditorInterface.get_resource_filesystem()
		if not file_system.is_scanning():
			file_system.scan()
