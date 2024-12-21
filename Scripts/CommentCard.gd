extends PanelContainer

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var content_label = %ContentLabel
@onready var updated_at = %UpdatedAt

signal comment_pressed(id: int, nickname: String)
signal delete_pressed(id: int)

var data: Dictionary

var menu

func set_comment_card_data(json: Dictionary):
	data = json
	var user: Dictionary
	if json.has("user"): user = json.get("user")
	elif json.has("reply_user"): user = json.get("reply_user")
	avatar_texture.load_image(user.get("avatar_url"))
	nickname_label.text = user.get("nickname")
	work_shop_tag.set_work_shop_data(user.get("work_shop_level"), \
			user.get("work_shop_name"), \
			user.get("subject_id"))
	content_label.text = json.get("content")
	var create_time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(json.get("created_at"))
	updated_at.text = "%s%s%s%s%s%s  %s:%s" %[
		create_time_dict.get("year"), \
		TranslationServer.translate("YEAR_NAME"), \
		create_time_dict.get("month"), \
		TranslationServer.translate("MONTH_NAME"), \
		create_time_dict.get("day"), \
		TranslationServer.translate("DAY_NAME1"), \
		create_time_dict.get("hour"), \
		create_time_dict.get("minute")
		]

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
	Application.append_address.emit(TranslationServer.translate("USER_NAME"), \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": int(data.get("user", {}).get("id", -1))})

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
