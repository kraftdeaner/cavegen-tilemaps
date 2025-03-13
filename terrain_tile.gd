extends StaticBody2D
@onready var tile: MeshInstance2D = $MeshInstance2D
@onready var tcol: CollisionShape2D = $CollisionShape2D

var noise_val = 0.0
var threshold = 0.0
var pos: Vector2i



var scalar: float
func _ready() -> void:
	Events.map_drawn.connect(_on_map_drawn)
	Events.tile_scale_slider_value_changed.connect(
											_on_tile_scale_slider_value_changed)
	pos = to_global(position)




func color_tile(r, g, b):
	tile.modulate = Color(r, g, b)


func _on_tile_scale_slider_value_changed(size):
	tile.mesh.set_deferred("size", Vector2(size, size))


func _on_map_drawn(map, chunk_tiles, map_size):
	#print("signal detected")
	var pos = global_position
	
	# Convert world position to tile coordinates
	var tile_x = int(pos.x / chunk_tiles) 
	var tile_y = int(pos.y / chunk_tiles)

	# Compute index correctly
	var index = tile_x * map_size + tile_y  

	# Debugging
	#print("Global Pos: ", global_position, 
		  #"\nTile X: ", tile_x, "   Tile Y: ", tile_y, 
		  #"\nIndex: ", index, "\nNoise Val: ", noise_val if index >= 0 and index < map.size() else "OUT OF BOUNDS")


	# Ensure within bounds
	if index >= 0 and index < map.size():
		noise_val = map[index]
	scalar = 0 if noise_val >= threshold else 1
	color_tile(scalar, scalar, scalar)
	tcol.disabled = scalar
