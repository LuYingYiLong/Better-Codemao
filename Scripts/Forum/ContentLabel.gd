extends RichTextLabel

func _ready() -> void:
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func _on_settings_config_update() -> void:
	if Settings.get_dark_mode(): add_theme_color_override("default_color", Color.html(GlobalTheme.dark_mode_font_color))
	else: add_theme_color_override("default_color", Color.html(GlobalTheme.light_mode_font_color))
