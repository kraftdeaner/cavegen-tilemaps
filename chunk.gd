class_name Chunk
extends Node2D

@onready var tmap: TileMapLayer = $TileMap

var size = Vector2i(16, 16)

func _ready() -> void:
	print(tmap.rendering_quadrant_size)
	#var cam = Camera2D.new()
	#cam.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	#cam.zoom = Vector2i(2, 2)
	#add_child(cam)
	for x in range(size.x):
		for y in range(size.y):
			tmap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0), 1)


func _draw() -> void:
	var qs = tmap.rendering_quadrant_size + 1
	draw_rect(Rect2i(Vector2i.ZERO, Vector2i(qs, qs) * Vector2i(15,15)), Color.DEEP_PINK, false)


#func generate_chunk(chunk_x, chunk_y): # Needs world values, maybe size, loop through tiles here
	#var scene
	#for x in range(chunk_x):
		#for y in range(chunk_y):
			## Place the tile, which auto-instantiates the scene
			#tmap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0), 1)
#
	## Now modify the instantiated scenes
	#
