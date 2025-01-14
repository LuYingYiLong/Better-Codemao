extends PanelContainer

@onready var image_url_loader = %ImageUrlLoader

@onready var name_label = %NameLabel
@onready var description_label = %DescriptionLabel
@onready var manager_label = %ManagerLabel
@onready var manager_avatar_texture = %ManagerAvatarTexture
@onready var sub_manager_label = %SubManagerLabel
@onready var sub_manager_1_avatar_texture = %SubManager1AvatarTexture
@onready var sub_manager_2_avatar_texture = %SubManager2AvatarTexture
@onready var sub_manager_3_avatar_texture = %SubManager3AvatarTexture
@onready var sub_manager_4_avatar_texture = %SubManager4AvatarTexture

var workshop_id: int
var manager_id: int
var sub_manager_1_id: int
var sub_manager_2_id: int
var sub_manager_3_id: int
var sub_manager_4_id: int

func _ready() -> void:
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func set_workshop_card_data(json: Dictionary):
	workshop_id = json.get("id")
	name_label.text = json.get("name")
	image_url_loader.load_image(json.get("preview_url"), name_label.text)
	description_label.text = json.get("description")
	var list_managers: Array = json.get("list_managers")
	var count: int = -1
	for manager: Dictionary in list_managers:
		count += 1
		match count:
			0:
				manager_id = manager.get("user_id")
				manager_avatar_texture.load_image(manager.get("avatar_url"))
			1:
				sub_manager_1_id = manager.get("user_id")
				sub_manager_1_avatar_texture.load_image(manager.get("avatar_url"))
				sub_manager_1_avatar_texture.show()
			2:
				sub_manager_2_id = manager.get("user_id")
				sub_manager_2_avatar_texture.load_image(manager.get("avatar_url"))
				sub_manager_2_avatar_texture.show()
			3:
				sub_manager_3_id = manager.get("user_id")
				sub_manager_3_avatar_texture.load_image(manager.get("avatar_url"))
				sub_manager_3_avatar_texture.show()
			4:
				sub_manager_4_id = manager.get("user_id")
				sub_manager_4_avatar_texture.load_image(manager.get("avatar_url"))
				sub_manager_4_avatar_texture.show()

func _on_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		Application.append_address.emit(name_label.text, \
			"res://Scenes/Workshop/ShopMenu.tscn", \
			{"id": workshop_id})

func _on_manager_avatar_texture_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		Application.append_address.emit(name_label.text, \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": manager_id})

func _on_sub_manager_1_avatar_texture_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		Application.append_address.emit(name_label.text, \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": sub_manager_1_id})

func _on_sub_manager_2_avatar_texture_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		Application.append_address.emit(name_label.text, \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": sub_manager_2_id})

func _on_sub_manager_3_avatar_texture_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		Application.append_address.emit(name_label.text, \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": sub_manager_3_id})

func _on_sub_manager_4_avatar_texture_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		Application.append_address.emit(name_label.text, \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": sub_manager_4_id})

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0:
		add_theme_stylebox_override("panel", load("res://Resources/Themes/DefaultPanelStyle.tres"))
		name_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		description_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		manager_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		sub_manager_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
	else:
		add_theme_stylebox_override("panel", load("res://Resources/Themes/DefaultPanelDarknessStyle.tres"))
		name_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		description_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		manager_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		sub_manager_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
