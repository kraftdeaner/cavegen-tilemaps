extends Node2D

@export var noise_texture : NoiseTexture2D
@onready var cmap_layer: TileMapLayer = $ChunkMap

var noise : Noise

# tiles in a chunk
const chunk_tiles : int = 16

# chunks in a map
var map_chunks : int = 2

var map_size = chunk_tiles * map_chunks
var width : int = map_size
var height : int = map_size

var noise_val_arr = []

func _ready() -> void:
	# set chunk map's tile (chunk) size in pixels
	cmap_layer.tile_set.tile_size = Vector2i(256, 256)
	#cmap_layer.position = Vector2i.ZERO
	noise = noise_texture.noise
	noise.seed = randi()
	generate_map()
	generate_world()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		var mpos = get_global_mouse_position()
		print(mpos)
		print(event.position)
		var tpos = cmap_layer.local_to_map(mpos)
		print(tpos)
		#var foo = get_tile_instance_at(tpos.x, tpos.y)
		#await get_tree().process_frame
		#var bar = foo.get_child(0)
		#print(bar)
		#cmap_layer.erase_cell(tpos)
		#cmap_layer.clear()




func generate_world():
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

func _draw() -> void:
	for x in range(width):
		for y in range(height):
			var index = x * height + y
			if noise_val_arr[index] >= 0:
				draw_circle(Vector2(x * 16, y * 16), 3, Color.FIREBRICK)
			else:
				draw_circle(Vector2(x * 16, y * 16), 3, Color.BLUE)
	

func get_tile_instance_at(x, y):
	var tile_pos = Vector2i(x, y)
	var tile_children = cmap_layer.get_used_cells_by_id(0)  # Get tiles with source ID 0
	for pos in tile_children:
		if pos == tile_pos:
			return cmap_layer.get_child(cmap_layer.get_child_count() - 1) # Last added child
	return null


func generate_map():
	#noise.seed = randi()
	for x in range(width):
		for y in range(height):
			var noise_val = noise.get_noise_2d(x, y)
			noise_val_arr.append(noise_val)
	# Wait a frame to ensure TileMap processed the changes
	await get_tree().process_frame 
	
	Events.map_drawn.emit(noise_val_arr, chunk_tiles, map_size)
	
	# Now modify the instantiated scenes
	
	
