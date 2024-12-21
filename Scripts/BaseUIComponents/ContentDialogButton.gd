extends Button

@export_enum("No Flat", "Flat") var style_type: int = 0:
	set(value):
		style_type = value
		if style_type == 0: theme = load("res://Resources/Themes/ButtonTheme4.tres")
		else: theme = load("res://Resources/Themes/ButtonTheme1.tres")
@export var index: int

signal on_pressed(index: int)

func _on_pressed():
	on_pressed.emit(index)
