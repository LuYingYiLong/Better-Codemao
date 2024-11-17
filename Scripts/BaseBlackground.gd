extends TextureRect

func _ready():
	Settings.settings_config_loaded.connect(_on_settings_config_update)
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func _on_settings_config_update():
	if !Settings.blackground.is_empty():
		var image = Image.new()
		image.load(Settings.blackground)
		var _texture = ImageTexture.create_from_image(image)
		texture = _texture
