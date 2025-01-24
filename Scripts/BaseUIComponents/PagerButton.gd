@tool
extends Button

const FLY_COLLAPSE_PAGES_MENU_SCENE = preload("res://Scenes/BaseUIComponents/PaginationBarComponents/FlyCollapsePagesMenu.tscn")
const ACCENT_BUTTON_LIGHT = preload("res://Resources/Themes/AccentButton-Light.tres")
const ACCENT_BUTTON_DARK = preload("res://Resources/Themes/AccentButton-Dark.tres")
const SIMPLE_BUTTON_LIGHT = preload("res://Resources/Themes/SimpleButton-Light.tres")
const SIMPLE_BUTTON_DARK = preload("res://Resources/Themes/SimpleButton-Dark.tres")

signal on_pressed(page: int)

var page: int = -1
var current_page: int = -1:
	set(value):
		current_page = value
		if !Engine.is_editor_hint():
			if page == current_page:
				if Settings.get_dark_mode(): theme = ACCENT_BUTTON_DARK
				else: theme = ACCENT_BUTTON_LIGHT
			else:
				if Settings.get_dark_mode(): theme = SIMPLE_BUTTON_DARK
				else: theme = SIMPLE_BUTTON_LIGHT
var collapse_pages: Vector2i

func set_page(_page: int) -> void:
	page = _page

func _on_pressed() -> void:
	if text == "...":
		var fly_collapse_pages_menu = FLY_COLLAPSE_PAGES_MENU_SCENE.instantiate()
		add_child(fly_collapse_pages_menu)
		fly_collapse_pages_menu.populate_collapse_pages(collapse_pages, current_page)
		@warning_ignore("narrowing_conversion")
		fly_collapse_pages_menu.position = Vector2i(global_position.x - 64, global_position.y - 160)
		fly_collapse_pages_menu.pressed.connect(_on_fly_collapse_pages_menu_pressed)
		fly_collapse_pages_menu.show_fly_collapse_pages_menu()
	else:
		on_pressed.emit(page)

func _on_fly_collapse_pages_menu_pressed(_page: int) -> void:
	on_pressed.emit(_page)
