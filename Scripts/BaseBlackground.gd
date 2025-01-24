extends TextureRect

@onready var base_blur = $"../BaseBlur"

var color: Color = DisplayServer.get_base_color()

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
	else:
		if Settings.get_dark_mode(): texture = load("res://Resources/Textures/DefaultDarkness.png")
		else: texture = load("res://Resources/Textures/Default.png")
	if Settings.blackground_mode == 1: base_blur.color = DisplayServer.get_base_color()
	base_blur.visible = Settings.blackground_mode == 1
