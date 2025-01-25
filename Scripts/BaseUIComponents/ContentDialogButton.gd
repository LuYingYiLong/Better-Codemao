extends Button


@export_enum("No Flat", "Flat") var style_type: int = 0:
	set(value):
		style_type = value
		if style_type == 0:
			if Settings.get_dark_mode(): theme = SIMPLE_BUTTON_DARK
			else: theme = SIMPLE_BUTTON_LIGHT
		else:
			if Settings.get_dark_mode(): theme = ACCENT_BUTTON_DARK
			else: theme = ACCENT_BUTTON_LIGHT
@export var index: int

signal on_pressed(index: int)

const ACCENT_BUTTON_LIGHT = preload("res://Resources/Themes/AccentButton-Light.tres")
const ACCENT_BUTTON_DARK = preload("res://Resources/Themes/AccentButton-Dark.tres")
const SIMPLE_BUTTON_LIGHT = preload("res://Resources/Themes/SimpleButton-Light.tres")
const SIMPLE_BUTTON_DARK = preload("res://Resources/Themes/SimpleButton-Dark.tres")

func _on_pressed():
	on_pressed.emit(index)
