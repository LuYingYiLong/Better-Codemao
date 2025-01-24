extends Node

@export var translucent: bool = false
@export_group("PanelContainer")
@export_enum("Style box", "Light color", "Dark color") var panel_container_style: int = 0

@onready var resource_preloader = %ResourcePreloader

func _ready() -> void:
	Settings.settings_config_update.connect(update_theme)
	update_theme()

func update_theme() -> void:
	var node = get_parent()
	var dark_mode = Settings.dark_mode
	if dark_mode == 2:
		var dark_mode_checker: DarkModeChecker = DarkModeChecker.new()
		dark_mode = int(dark_mode_checker.is_dark_mode_enabled())
	if dark_mode == 0:
		if node is PanelContainer and node.get_theme_stylebox("panel") != null:
			if panel_container_style == 0:
				var file_name: String = get_panel_resource_name(node)
				if !has_theme_suffix(file_name): return
				if get_res_theme(file_name) != dark_mode: node.add_theme_stylebox_override("panel", get_opposite_theme(node.get_theme_stylebox("panel")))
			elif panel_container_style >= 1:
				var style_box: StyleBox = node.get_theme_stylebox("panel")
				if style_box is StyleBoxFlat:
					if panel_container_style == 1: style_box.bg_color = Color.html("#ffffff")
					elif panel_container_style == 2: style_box.bg_color = Color.html("#f3f3f3")
					style_box.border_color = Color.html("#e5e5e5")

		if node is Label:
			if translucent: node.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_translucent_palette))
			else: node.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_palette))
		if (node is Button or \
				node is ScrollContainer or \
				node is LineEdit or \
				node is TextEdit) \
				and node.theme != null:
			var file_name: String = get_theme_resource_name(node)
			if !has_theme_suffix(file_name): return
			if get_res_theme(file_name) != dark_mode: node.theme = get_opposite_theme(node.theme)
		if node is TextureRect:
			if translucent: node.self_modulate = Color.html(GlobalTheme.light_mode_translucent_palette)
			else: node.self_modulate = Color.html(GlobalTheme.light_mode_palette)

	elif dark_mode == 1:
		if node is PanelContainer and node.get_theme_stylebox("panel") != null:
			if panel_container_style == 0:
				var file_name: String = get_panel_resource_name(node)
				if !has_theme_suffix(file_name): return
				if get_res_theme(file_name) != dark_mode: node.add_theme_stylebox_override("panel", get_opposite_theme(node.get_theme_stylebox("panel")))
			elif panel_container_style >= 1:
				var style_box: StyleBox = node.get_theme_stylebox("panel")
				if style_box is StyleBoxFlat:
					if panel_container_style == 1: style_box.bg_color = Color.html("#2b2b2b")
					elif panel_container_style == 2: style_box.bg_color = Color.html("#202020")
					style_box.border_color = Color.html("#3a3a3a")

		if node is Label: node.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		if (node is Button or \
				node is ScrollContainer or \
				node is LineEdit or \
				node is TextEdit) \
				and node.theme != null:
			var file_name: String = get_theme_resource_name(node)
			if !has_theme_suffix(file_name): return
			if get_res_theme(file_name) != dark_mode: node.theme = get_opposite_theme(node.theme)
		if node is TextureRect:
			if translucent: node.self_modulate = Color.html(GlobalTheme.dark_mode_translucent_palette)
			else: node.self_modulate = Color.html(GlobalTheme.dark_mode_palette)
		if node is QRCodeRect:
			node.light_module_color = Color.html("2b2b2b")
			node.dark_module_color = Color.html("ffffff")

func get_panel_resource_name(node) -> String:
	return node.get_theme_stylebox("panel").resource_path.get_file().trim_suffix(".tres")

func get_theme_resource_name(node) -> String:
	return node.theme.resource_path.get_file().trim_suffix(".tres")

func has_theme_suffix(file_name: String) -> bool:
	return file_name.ends_with("Light") or file_name.ends_with("Dark")

# 获取相反的主题样式
func get_opposite_theme(res: Resource) -> Resource:
	if null: return null
	var res_name: StringName = res.resource_path.get_file().trim_suffix(".tres")
	if get_res_theme(res_name) == 0:
		res_name = res_name.trim_suffix("-Light")
		return resource_preloader.get_resource("%s-Dark" %res_name)
	elif get_res_theme(res_name) == 1:
		res_name = res_name.trim_suffix("-Dark")
		return resource_preloader.get_resource("%s-Light" %res_name)
	else: return res

func get_res_theme(file_name: String) -> int:
	if file_name.ends_with("Light"): return 0
	elif  file_name.ends_with("Dark"): return 1
	return -1
