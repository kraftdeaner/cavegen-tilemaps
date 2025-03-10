extends Node2D
@onready var tile: MeshInstance2D = $MeshInstance2D

var noise_val = 0.0
var threshold = 0.0

func _ready() -> void:
	Events.map_drawn.connect(_on_map_drawn)

func _process(delta: float) -> void:
	#color_tile( 1 if position.x > 128 else 0, 1 if position.y > 128 else 0, 0)
	color_tile( 1 if noise_val >= threshold else 0, 1 if noise_val < threshold else 0, 1)
	#pass

func color_tile(r, g, b):
	tile.modulate = Color(r, g, b)

func _on_map_drawn(map, chunk_tiles, map_size):
	print("signal detected")
	#var pos = to_global(position)
	var tile_x = int(position.x / chunk_tiles)
	print(tile_x)
	var tile_y = int(position.y / chunk_tiles)
	print(tile_y)
	var index = tile_x * map_size + tile_y
	
	if index >= 0 and index < map.size():
		noise_val = map[index]
