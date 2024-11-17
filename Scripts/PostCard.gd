extends PanelContainer

@onready var details_request = %DetailsRequest

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var title_label = %TitleLabel
@onready var content_label = %ContentLabel

signal pressed(data: Dictionary)

var data: Dictionary

func set_post_card_id(id: String):
	details_request.request_completed.connect(on_details_received)
	details_request.request("https://api.codemao.cn/web/forums/posts/%s/details" %id)

func on_details_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		queue_free()
		return

	set_post_card_data(json)

func set_post_card_data(_data: Dictionary):
	if _data.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[_data.get("error_code", ""), _data.get("error_message", "")])
		return
	data = _data
	var user: Dictionary = data.get("user", {})
	nickname_label.text = user.get("nickname", "ERROR")
	avatar_texture.load_image(user.get("avatar_url"))
	work_shop_tag.set_work_shop_data(user.get("work_shop_level", 0), \
			user.get("work_shop_name", ""), \
			user.get("subject_id", 0))
	title_label.text = data.get("title")
	content_label.text = Application.html_to_text(data.get("content"))

func _on_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		pressed.emit(data)

func _on_avatar_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		jump_to_user_menu()

func jump_to_user_menu():
	Application.append_address.emit(TranslationServer.translate("USER_NAME"), \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": data.get("user", {}).get("id", -1).to_int()})
