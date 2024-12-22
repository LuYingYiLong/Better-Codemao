extends Node

var automatic_login: bool = false
var blackground: String = ""
var blackground_mode: int = 0
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
		blackground_mode= file.get_value("personalization", "blackground_mode", 0)
		anti_aliasing = file.get_value("video", "anti_aliasing", ANTI_ALIASING.DISABLED)
		language = file.get_value("language", "language", "ch")
	else:
		push_warning("Failed to load config: %d" %error)
	settings_config_loaded.emit()

func open_user_folder():
	OS.shell_open(ProjectSettings.globalize_path("user://"))
