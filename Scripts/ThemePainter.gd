extends Node

@export var translucent: bool = false

const ACCENT_BUTTON_LIGHT = preload("res://Resources/Themes/AccentButton-Light.tres")
const ACCENT_BUTTON_DARK = preload("res://Resources/Themes/AccentButton-Dark.tres")
const SIMPLE_BUTTON_LIGHT = preload("res://Resources/Themes/SimpleButton-Light.tres")
const SIMPLE_BUTTON_DARK = preload("res://Resources/Themes/SimpleButton-Dark.tres")
const PANEL_CONTAINER_LIGHT = preload("res://Resources/Themes/PanelContainer-Light.tres")
const PANEL_CONTAINER_DARK = preload("res://Resources/Themes/PanelContainer-Dark.tres")
const HLINE_LIGHT = preload("res://Resources/Themes/HLine-Light.tres")
const HLINE_DARK = preload("res://Resources/Themes/HLine-Dark.tres")
const VLINE_LIGHT = preload("res://Resources/Themes/VLine-Light.tres")
const VLINE_DARK = preload("res://Resources/Themes/VLine-Dark.tres")
const FLAT_BUTTON_LIGHT = preload("res://Resources/Themes/FlatButton-Light.tres")
const FLAT_BUTTON_DARK = preload("res://Resources/Themes/FlatButton-Dark.tres")
const SMALL_BUTTON_LIGHT = preload("res://Resources/Themes/SmallButton-Light.tres")
const SMALL_BUTTON_DARK = preload("res://Resources/Themes/SmallButton-Dark.tres")
const SCROLL_CONTAINER_LIGHT = preload("res://Resources/Themes/ScrollContainer-Light.tres")
const SCROLL_CONTAINER_DARK = preload("res://Resources/Themes/SmallButton-Dark.tres")
const LINE_EDIT_LIGHT = preload("res://Resources/Themes/LineEdit-Light.tres")
const LINE_EDIT_DARK = preload("res://Resources/Themes/LineEdit-Dark.tres")
const HYPERLINK_LIGHT = preload("res://Resources/Themes/Hyperlink-Light.tres")
const HYPERLINK_DARK = preload("res://Resources/Themes/Hyperlink-Dark.tres")

var relative_resources: Dictionary = {
	"AccentButton-Light.tres": ACCENT_BUTTON_DARK, 
	"AccentButton-Dark.tres": ACCENT_BUTTON_LIGHT, 
	"SimpleButton-Light.tres": SIMPLE_BUTTON_DARK, 
	"SimpleButton-Dark.tres": SIMPLE_BUTTON_LIGHT, 
	"PanelContainer-Light.tres": PANEL_CONTAINER_DARK, 
	"PanelContainer-Dark.tres": PANEL_CONTAINER_LIGHT, 
	"HLine-Light.tres": HLINE_DARK, 
	"HLine-Dark.tres": HLINE_LIGHT, 
	"VLine-Light.tres": VLINE_DARK, 
	"VLine-Dark.tres": VLINE_LIGHT, 
	"FlatButton-Light.tres": FLAT_BUTTON_DARK, 
	"FlatButton-Dark.tres": FLAT_BUTTON_LIGHT, 
	"SmallButton-Light.tres": SMALL_BUTTON_DARK, 
	"SmallButton-Dark.tres": SMALL_BUTTON_LIGHT, 
	"ScrollContainer-Light.tres": SCROLL_CONTAINER_DARK, 
	"ScrollContainer-Dark.tres": SCROLL_CONTAINER_LIGHT, 
	"LineEdit-Light.tres": LINE_EDIT_DARK, 
	"LineEdit-Dark.tres": LINE_EDIT_LIGHT, 
	"Hyperlink-Light.tres": HYPERLINK_DARK, 
	"Hyperlink-Dark.tres": HYPERLINK_LIGHT
}

func _ready() -> void:
	if Settings.dark_mode == 1:
		var node = get_parent()
		if node is PanelContainer and node.get_theme_stylebox("panel") is StyleBoxFlat:
			node.add_theme_stylebox_override("panel", relative_resources.get(node.get_theme_stylebox("panel").resource_path.get_file()))
		if node is Label: node.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		if (node is Button or \
				node is ScrollContainer or \
				node is LineEdit) \
				and node.theme != null:
			node.theme = relative_resources.get(node.theme.resource_path.get_file())
		if node is TextEdit:
			node.add_theme_color_override("font_readonly_color", Color.html(GlobalTheme.dark_mode_font_color))
			node.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
			node.add_theme_color_override("caret_color", Color.html(GlobalTheme.dark_mode_palette))
		if node is TextureRect:
			if translucent: node.self_modulate = Color.html(GlobalTheme.dark_mode_translucent_palette)
			else: node.self_modulate = Color.html(GlobalTheme.dark_mode_palette)
