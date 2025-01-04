extends Button

const BUTTON_THEME1 = preload("res://Resources/Themes/ButtonTheme1.tres")
const BUTTON_THEME4 = preload("res://Resources/Themes/ButtonTheme4.tres")

var page: int = -1
var current_page: int = -1:
	set(value):
		current_page = value
		if page == current_page: theme = BUTTON_THEME1
		else: theme = BUTTON_THEME4

signal page_pressed(page: int)

func _on_pressed() -> void:
	page_pressed.emit(page)
