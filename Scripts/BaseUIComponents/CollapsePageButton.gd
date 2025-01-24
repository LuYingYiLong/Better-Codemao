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
			if Settings.get_dark_mode(): theme = ACCENT_BUTTON_DARK
			else: theme = ACCENT_BUTTON_LIGHT
		else:
			if Settings.get_dark_mode(): theme = SIMPLE_BUTTON_DARK
			else: theme = SIMPLE_BUTTON_LIGHT

signal page_pressed(page: int)

func _on_pressed() -> void:
	page_pressed.emit(page)
