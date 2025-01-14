extends Node

func update_theme(dark_mode: int = -1) -> void:
	if dark_mode == -1: dark_mode = Settings.dark_mode
	if dark_mode == 0:
		for node in get_tree().get_nodes_in_group("theme-normal"):
			if node is PanelContainer: node.add_theme_stylebox_override("panel", load("res://Resources/Themes/DefaultPanelStyle.tres"))
			if node is Label: node.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
			if node is Button:
				node.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
				node.add_theme_color_override("font_focus_color", Color.html(GlobalTheme.light_mode_font_color))
				node.add_theme_color_override("font_hover_color", Color.html(GlobalTheme.light_mode_font_color))
				node.add_theme_color_override("font_hover_pressed_color", Color.html(GlobalTheme.light_mode_font_color))
				node.add_theme_color_override("font_pressed_color", Color.html(GlobalTheme.light_mode_font_color))
				node.add_theme_color_override("icon_normal_color", Color.html(GlobalTheme.light_mode_icon_color))
				node.add_theme_color_override("icon_focus_color", Color.html(GlobalTheme.light_mode_icon_color))
				node.add_theme_color_override("icon_hover_color", Color.html(GlobalTheme.light_mode_icon_color))
				node.add_theme_color_override("icon_hover_pressed_color", Color.html(GlobalTheme.light_mode_icon_color))
				node.add_theme_color_override("icon_pressed_color", Color.html(GlobalTheme.light_mode_icon_color))
			if node is TextEdit:
				node.add_theme_color_override("font_readonly_color", Color.html(GlobalTheme.light_mode_font_color))
				node.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
	else:
		for node in get_tree().get_nodes_in_group("theme-normal"):
			if node is PanelContainer: node.add_theme_stylebox_override("panel", load("res://Resources/Themes/DefaultPanelDarknessStyle.tres"))
			if node is Label: node.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
			if node is Button:
				node.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
				node.add_theme_color_override("font_focus_color", Color.html(GlobalTheme.dark_mode_font_color))
				node.add_theme_color_override("font_hover_color", Color.html(GlobalTheme.dark_mode_font_color))
				node.add_theme_color_override("font_hover_pressed_color", Color.html(GlobalTheme.dark_mode_font_color))
				node.add_theme_color_override("font_pressed_color", Color.html(GlobalTheme.dark_mode_font_color))
				node.add_theme_color_override("icon_normal_color", Color.html(GlobalTheme.dark_mode_icon_color))
				node.add_theme_color_override("icon_focus_color", Color.html(GlobalTheme.dark_mode_icon_color))
				node.add_theme_color_override("icon_hover_color", Color.html(GlobalTheme.dark_mode_icon_color))
				node.add_theme_color_override("icon_hover_pressed_color", Color.html(GlobalTheme.dark_mode_icon_color))
				node.add_theme_color_override("icon_pressed_color", Color.html(GlobalTheme.dark_mode_icon_color))
			if node is TextEdit:
				node.add_theme_color_override("font_readonly_color", Color.html(GlobalTheme.dark_mode_font_color))
				node.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
