extends RichTextLabel

func _ready() -> void:
	Settings.settings_config_update.connect(theme_update)
	theme_update()

func theme_update() -> void:
	var dark_mode: bool = Settings.get_dark_mode()
	
	if dark_mode: add_theme_color_override("default_color", Color.html(GlobalTheme.dark_mode_font_color))
	else: add_theme_color_override("default_color", Color.html(GlobalTheme.light_mode_font_color))
