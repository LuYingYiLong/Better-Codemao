extends Button

const ACCENT_BUTTON_LIGHT = preload("res://Resources/Themes/AccentButton-Light.tres")
const ACCENT_BUTTON_DARK = preload("res://Resources/Themes/AccentButton-Dark.tres")
const SIMPLE_BUTTON_LIGHT = preload("res://Resources/Themes/SimpleButton-Light.tres")
const SIMPLE_BUTTON_DARK = preload("res://Resources/Themes/SimpleButton-Dark.tres")

var page: int = -1
var current_page: int = -1:
	set(value):
		current_page = value
		if page == current_page:
			if Settings.dark_mode == 0: theme = ACCENT_BUTTON_LIGHT
			else: theme = ACCENT_BUTTON_DARK
		else:
			if Settings.dark_mode == 0: theme = SIMPLE_BUTTON_LIGHT
			else: theme = SIMPLE_BUTTON_DARK

signal page_pressed(page: int)

func _on_pressed() -> void:
	page_pressed.emit(page)
