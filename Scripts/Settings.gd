extends Node

var automatic_login: bool = false
var blackground: String = ""
var blackground_mode: int = 0
var dark_mode: int = 0:
	set(value):
		dark_mode = value
		update_theme()
var anti_aliasing: int = ANTI_ALIASING.DISABLED
var language: String = "ch":
	set(value):
		language = value
		TranslationServer.set_locale(language)

enum ANTI_ALIASING{DISABLED, MSAA3D_2X, MSAA3D_4X, MSAA3D_8X}

const SETTINGS_CONFIG_PATH = "user://SettingsConfig.cfg"#设置配置文件保存

signal settings_config_update
signal settings_config_loaded

func _ready():
	if !FileAccess.file_exists(ProjectSettings.globalize_path("user://SettingsConfig.cfg")):
		save_settings_config()
	var dir_access: DirAccess = DirAccess.open("user://")
	dir_access.make_dir("Personalization")
	dir_access.make_dir("Files")
	load_settings_config()
	TranslationServer.set_locale(language)

#保存设置配置文件
func save_settings_config():
	var file = ConfigFile.new()
	file.set_value("user", "automatic_login", automatic_login)
	file.set_value("personalization", "blackground", blackground)
	file.set_value("personalization", "blackground_mode", blackground_mode)
	file.set_value("personalize", "dark_mode", dark_mode)
	file.set_value("video", "anti_aliasing", anti_aliasing)
	file.set_value("language", "language", language)
	var error = file.save(SETTINGS_CONFIG_PATH)
	if error != OK:
		push_error("Failed to save config: %d" %error)
	settings_config_update.emit()

#加载设置配置文件
func load_settings_config():
	var file = ConfigFile.new()
	var error = file.load(SETTINGS_CONFIG_PATH)
	if error == OK:
		automatic_login = file.get_value("user", "automatic_login", false)
		blackground = file.get_value("personalization", "blackground", "")
		blackground_mode = file.get_value("personalization", "blackground_mode", 0)
		dark_mode = file.get_value("personalize", "dark_mode", 0)
		anti_aliasing = file.get_value("video", "anti_aliasing", ANTI_ALIASING.DISABLED)
		language = file.get_value("language", "language", "ch")
	else:
		push_warning("Failed to load config: %d" %error)
	settings_config_loaded.emit()

func update_theme() -> void:
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
		for node in get_tree().get_nodes_in_group("theme-v_separator"):
			node.add_theme_stylebox_override("panel", load("res://Resources/Themes/VLine-Dark.tres"))

func open_user_folder():
	OS.shell_open(ProjectSettings.globalize_path("user://"))
