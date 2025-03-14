extends Node2D

@export var noise_texture : NoiseTexture2D

@export var chunk_render_dist: int = 4
@export var chunk_update_interval: float = 1.0  # Update chunks every 1 second


@onready var cmap_layer: TileMapLayer = $ChunkMap
@onready var player: CharacterBody2D = $Player

var noise : Noise

# tiles in a chunk
const chunk_tiles : int = 16

# chunks in a map
var map_chunks : int = 32

var map_size = chunk_tiles * map_chunks
var width : int = map_size
var height : int = map_size

var noise_val_arr = []
var noise_map = {}

func _ready() -> void:
	
	Events.refresh_seed_button_pressed.connect(reset_world)
	# set chunk map's tile (chunk) size in pixels
	cmap_layer.tile_set.tile_size = Vector2i(256, 256)
	#cmap_layer.position = Vector2i.ZERO
	noise = noise_texture.noise
	noise.seed = randi()
	update_chunks()
	add_chunk_timer()


func _input(event: InputEvent) -> void:
	var mpos = get_global_mouse_position()
	if Input.is_action_just_pressed("click"):
		print("Event position: ", event.position) # pos in screen (respects cam)
		
		print("Global mouse position: ", mpos) # pos in world (chunkmap's mom) 
		var cpos = cmap_layer.local_to_map(mpos)
		print("Chunk position: ", cpos) # chunk coordinates in chunkmap
		var tpos: Vector2i = floor(mpos / 16)
		print("Tile position: ", tpos)
		if cmap_layer.get_cell_source_id(cpos) == -1:
			
			cmap_layer.set_cell(cpos, 2, Vector2i(0, 0), 1)
		else:
			cmap_layer.erase_cell(cpos)
		#player.global_position = mpos
	if Input.is_action_just_pressed("right_click"):
		player.global_position = mpos


func generate_world():
	#generate_map()
	for x in range(map_chunks):
		for y in range(map_chunks):
			
			# Place the tile, which auto-instantiates the scene
			cmap_layer.set_cell(Vector2i(x , y), 2, Vector2i(0, 0), 1)
			
			var source_id = cmap_layer.get_cell_source_id(Vector2i(x, y))
			if source_id > -1:
				var scene_source = cmap_layer.tile_set.get_source(source_id)
				if scene_source is TileSetScenesCollectionSource:
					var alt_id = cmap_layer.get_cell_alternative_tile(Vector2i(x, y))
					# The assigned PackedScene.
					var scene = scene_source.get_scene_tile_scene(alt_id)


func update_chunks():
	var player_chunk = get_player_chunk()
	var chunks_keep = get_chunks_within_distance(player_chunk, chunk_render_dist)

	generate_map_for_chunks(chunks_keep)  # ✅ Update only relevant chunks

	var existing_chunks = cmap_layer.get_used_cells()
	var to_remove = []

	for chunk in existing_chunks:
		if chunk not in chunks_keep:
			to_remove.append(chunk)

	for chunk in to_remove:
		cmap_layer.erase_cell(chunk)  # Remove unused chunks

func process_chunks_in_batches(to_add, to_remove):
	var batch_size = 10  # Adjust based on performance
	while to_add.size() > 0 or to_remove.size() > 0:
		for i in range(min(batch_size, to_add.size())):
			cmap_layer.set_cell(to_add.pop_front(), 2, Vector2i(0,0), 1)
		for i in range(min(batch_size, to_remove.size())):
			cmap_layer.erase_cell(to_remove.pop_front())
		await get_tree().process_frame  # Yield to avoid freezing the main thread


func get_player_chunk() -> Vector2i:
	return cmap_layer.local_to_map(player.global_position)


func get_chunks_within_distance(start_chunk, max_distance) -> Array:
	var visited_chunks = {}
	var queue = [start_chunk]
	visited_chunks[start_chunk] = true
	
	for i in range(max_distance):
		var next_queue = []
		for chunk in queue:
			for neighbor in cmap_layer.get_surrounding_cells(chunk):
				if neighbor not in visited_chunks:
					visited_chunks[neighbor] = true
					next_queue.append(neighbor)
		queue = next_queue
	
	return visited_chunks.keys()


func add_chunk_timer():
	var chunk_update_timer = Timer.new()
	chunk_update_timer.wait_time = chunk_update_interval
	chunk_update_timer.autostart = true
	chunk_update_timer.one_shot = false
	chunk_update_timer.timeout.connect(update_chunks)
	add_child(chunk_update_timer)  # Attach timer to the node



func reset_world():
	noise_val_arr = []
	cmap_layer.clear()
	noise.seed = randi()
	update_chunks()
	queue_redraw()


#func _draw() -> void:
	#for x in range(width):
		#for y in range(height):
			#var index = x * height + y
			#if noise_val_arr[index] >= 0:
				#draw_circle(Vector2(x * 16, y * 16), 3, Color.FIREBRICK)
			#else:
				#draw_circle(Vector2(x * 16, y * 16), 3, Color.BLUE)


func get_tile_instance_at(x, y):
	var tile_pos = Vector2i(x, y)
	var tile_children = cmap_layer.get_used_cells_by_id(0)  # Get tiles with source ID 0
	for pos in tile_children:
		if pos == tile_pos:
			return cmap_layer.get_child(cmap_layer.get_child_count() - 1) # Last added child
	return null




func generate_map_for_chunks(chunks_keep):
	for chunk in chunks_keep:
		var chunk_x = chunk.x * chunk_tiles
		var chunk_y = chunk.y * chunk_tiles
		var chunk_noise = []  # Store chunk-specific noise values
		
		for x in range(chunk_x, chunk_x + chunk_tiles):
			for y in range(chunk_y, chunk_y + chunk_tiles):
				chunk_noise.append(noise.get_noise_2d(x, y))

		noise_map[chunk] = chunk_noise  # Store in dictionary

	await get_tree().process_frame  # Prevent freezing
	Events.map_drawn.emit(noise_map, chunk_tiles, map_size)


func _on_chunk_map_changed() -> void:
	print("changed!")
