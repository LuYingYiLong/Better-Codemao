extends Button


@export_enum("No Flat", "Flat") var style_type: int = 0:
	set(value):
		style_type = value
		if style_type == 0:
			if Settings.dark_mode == 0: theme = SIMPLE_BUTTON_LIGHT
			else: theme = SIMPLE_BUTTON_DARK
		else:
			if Settings.dark_mode == 0: theme = ACCENT_BUTTON_LIGHT
			else: theme = ACCENT_BUTTON_DARK
@export var index: int

signal on_pressed(index: int)

const ACCENT_BUTTON_LIGHT = preload("res://Resources/Themes/AccentButton-Light.tres")
const ACCENT_BUTTON_DARK = preload("res://Resources/Themes/AccentButton-Dark.tres")
const SIMPLE_BUTTON_LIGHT = preload("res://Resources/Themes/SimpleButton-Light.tres")
const SIMPLE_BUTTON_DARK = preload("res://Resources/Themes/SimpleButton-Dark.tres")

func _on_pressed():
	on_pressed.emit(index)
