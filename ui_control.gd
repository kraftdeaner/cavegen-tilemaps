extends Control

@onready var tile_scale: VSlider = $TileScale
@onready var refresh_seed: Button = $RefreshSeed
var tile_size: float




func _on_tile_scale_value_changed(value: float) -> void:
	Events.tile_scale_slider_value_changed.emit(value)





func _on_refresh_seed_pressed() -> void:
	refresh_seed.release_focus()
	Events.refresh_seed_button_pressed.emit()
	pass # Replace with function body.
