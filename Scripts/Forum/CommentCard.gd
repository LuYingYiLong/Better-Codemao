extends PanelContainer

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var drop_down_button = %DropDownButton
@onready var content_label = %ContentLabel
@onready var updated_at = %UpdatedAt

signal comment_pressed(id: int, nickname: String)
signal delete_pressed(id: int)

var data: Dictionary

var menu

func _ready() -> void:
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func set_comment_card_data(json: Dictionary):
	data = json
	var user: Dictionary
	if json.has("user"): user = json.get("user")
	elif json.has("reply_user"): user = json.get("reply_user")
	avatar_texture.load_image(user.get("avatar_url"), user.get("nickname"))
	nickname_label.text = user.get("nickname")
	work_shop_tag.set_work_shop_data(user.get("work_shop_level"), \
			user.get("work_shop_name"), \
			user.get("subject_id"))
	var reply_popup_item: PopupItem = PopupItem.new()
	reply_popup_item.text = "REPLY_NAME"
	drop_down_button.popup_items.append(reply_popup_item)
	if int(user.get("id")) == Application.user_id:
		var delete_popup_item: PopupItem = PopupItem.new()
		delete_popup_item.text = "DELETE_NAME"
		drop_down_button.popup_items.append(delete_popup_item)
	content_label.text = json.get("content")
	updated_at.text = Application.format_relative_time(json.get("created_at"))

func _menu_callback(item_id: int) -> void:
	if item_id == 0:
		var user: Dictionary = data.get("user")
		comment_pressed.emit(data.get("id").to_int(), user.get("nickname"))
	elif item_id == 1:
		delete_pressed.emit(data.get("id").to_int())

func _on_avatar_texture_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		jump_to_user_menu()

func _on_nickname_label_pressed():
	jump_to_user_menu()

func jump_to_user_menu():
	var user: Dictionary
	if data.has("user"): user = data.get("user")
	elif data.has("reply_user"): user = data.get("reply_user")
	Application.append_address.emit(user.get("nickname", "USER_NAME"), \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": int(user.get("id", -1))})

func _on_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_index == 2 and \
			event.button_mask == 2:
		if menu != null: NativeMenu.free_menu(menu)
		menu = NativeMenu.create_menu()
		NativeMenu.add_item(menu, TranslationServer.translate("REPLY_NAME"), _menu_callback, Callable(), 0)
		if data.get("user").get("id").to_int() == Application.user_id: NativeMenu.add_item(menu, TranslationServer.translate("DELETE_NAME"), _menu_callback, Callable(), 1)
		NativeMenu.popup(menu, DisplayServer.mouse_get_position())

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0:
		nickname_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		nickname_label.add_theme_color_override("font_focus_color", Color.html(GlobalTheme.light_mode_font_color))
		nickname_label.add_theme_color_override("font_hover_color", Color.html(GlobalTheme.light_mode_font_color))
		nickname_label.add_theme_color_override("font_hover_pressed_color", Color.html(GlobalTheme.light_mode_font_color))
		nickname_label.add_theme_color_override("font_pressed_color", Color.html(GlobalTheme.light_mode_font_color))
		updated_at.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
	else:
		nickname_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		nickname_label.add_theme_color_override("font_focus_color", Color.html(GlobalTheme.dark_mode_font_color))
		nickname_label.add_theme_color_override("font_hover_color", Color.html(GlobalTheme.dark_mode_font_color))
		nickname_label.add_theme_color_override("font_hover_pressed_color", Color.html(GlobalTheme.dark_mode_font_color))
		nickname_label.add_theme_color_override("font_pressed_color", Color.html(GlobalTheme.dark_mode_font_color))
		updated_at.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
