extends PanelContainer

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var manager_info = %ManagerInfo
@onready var sub_manager_info = %SubManagerInfo

signal pressed(nick_name: String, user_id: int)

var user_id: int

func _ready() -> void:
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func set_member_card_data(data: Dictionary) -> void:
	user_id = data.get("id")
	avatar_texture.load_image(data.get("avatar_url"), data.get("name"))
	nickname_label.text = data.get("name")
	var pos: String = data.get("position")
	manager_info.visible = pos == "LEADER"
	sub_manager_info.visible = pos == "DEPUTYLEADER"

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0:
		add_theme_stylebox_override("panel", load("res://Resources/Themes/DefaultPanelStyle.tres"))
		nickname_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
	else:
		add_theme_stylebox_override("panel", load("res://Resources/Themes/DefaultPanelDarknessStyle.tres"))
		nickname_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))

func _on_button_pressed() -> void:
	pressed.emit(nickname_label.text, user_id)
