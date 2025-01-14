extends PanelContainer

func _ready() -> void:
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0: add_theme_stylebox_override("panel", load("res://Resources/Themes/VLine-Light.tres"))
	else: add_theme_stylebox_override("panel", load("res://Resources/Themes/VLine-Dark.tres"))
