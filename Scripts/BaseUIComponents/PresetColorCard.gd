extends Button

@onready var color_rect = %ColorRect

signal select_color(color: Color)

func set_color(color: Color) -> void:
	color_rect.color = color

func _on_pressed():
	select_color.emit(color_rect.color)
