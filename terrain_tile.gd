extends Node2D
@onready var tile: MeshInstance2D = $MeshInstance2D

func _ready() -> void:
	color_tile(1, 1, 1)


func _process(delta: float) -> void:
	color_tile( 1 if position.x > 128 else 0, 1 if position.y > 128 else 0, 0)


func color_tile(r, g, b):
	tile.modulate = Color(r, g, b)
