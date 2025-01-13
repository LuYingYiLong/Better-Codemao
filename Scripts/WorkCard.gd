extends PanelContainer

@onready var preview_texture = %PreviewTexture
@onready var work_name_label = %WorkNameLabel
@onready var description_label = %DescriptionLabel

var id: int

func _ready() -> void:
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()
	
func set_work_card_data(json: Dictionary) -> void:
	id = json.get("id")
	if json.has("work_name"):
		work_name_label.text = json.get("work_name")
		preview_texture.load_image(json.get("preview"), json.get("work_name"))
	elif json.has("name"):
		work_name_label.text = json.get("name")
		preview_texture.load_image(json.get("preview"), json.get("name"))
	description_label.text = json.get("description", "")

func _on_preview_texture_pressed() -> void:
	Application.append_address.emit(work_name_label.text, \
			"res://Scenes/Work/WorkMenu.tscn", \
			{"id": id})

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0:
		work_name_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		description_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
	else:
		work_name_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		description_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
