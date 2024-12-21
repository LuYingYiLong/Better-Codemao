extends TextureRect

@onready var base_blur = $"../BaseBlur"

var color: Color = DisplayServer.get_base_color()

func _ready():
	base_blur.color = DisplayServer.get_base_color()
	Settings.settings_config_loaded.connect(_on_settings_config_update)
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

#func _notification(what):
	#if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		#base_blur.color = Color.html("#eff4f9")
	#elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		#base_blur.color = DisplayServer.get_base_color()

#func _process(delta):
	#var image: Image = Image.new()
#	image = DisplayServer.screen_get_image(DisplayServer.get_primary_screen())
	#base_blur.color.r = lerpf(base_blur.color.r, color.r, delta)
	#base_blur.color.g = lerpf(base_blur.color.g, color.g, delta)
	#base_blur.color.b = lerpf(base_blur.color.b, color.b, delta)

func _on_settings_config_update():
	if !Settings.blackground.is_empty():
		var image = Image.new()
		image.load(Settings.blackground)
		var _texture = ImageTexture.create_from_image(image)
		texture = _texture
