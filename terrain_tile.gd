extends Node2D
@onready var tile: MeshInstance2D = $MeshInstance2D

var noise_val = 0.0
var threshold = 0.0
var pos: Vector2i

var scalar: float
func _ready() -> void:
	Events.map_drawn.connect(_on_map_drawn)
	pos = to_global(position)
	
func _process(delta: float) -> void:
	scalar = 0 if noise_val >= threshold else 1 

	
	#color_tile( 1 if position.x > 128 else 0, 1 if position.y > 128 else 0, 0)
	color_tile(scalar, scalar, scalar)
	#color_tile( 0 if noise_val >= threshold else 1, 0 if noise_val < threshold else 1, 0)
	#color_tile( 1 if pos.x < 256 or noise_val >= threshold else 0, 1 if noise_val < threshold else 0, 1)
	#pass

func color_tile(r, g, b):
	tile.modulate = Color(r, g, b)

func _on_map_drawn(map, chunk_tiles, map_size):
	print("signal detected")

	# Get global position ONCE
	var pos = global_position
	
	# Convert world position to tile coordinates
	var tile_x = int(pos.x /16)  # Assuming each tile is 16x16 pixels
	var tile_y = int(pos.y /16)

	# Compute index correctly
	var index = tile_x * map_size + tile_y  

	# Debugging
	print("Global Pos: ", global_position, 
		  "\nTile X: ", tile_x, "   Tile Y: ", tile_y, 
		  "\nIndex: ", index, "\nNoise Val: ", noise_val if index >= 0 and index < map.size() else "OUT OF BOUNDS")


	# Ensure within bounds
	if index >= 0 and index < map.size():
		noise_val = map[index]
