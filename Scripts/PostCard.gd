extends PanelContainer

@onready var details_request = %DetailsRequest

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var create_time = %CreateTime

@onready var post_authorized_tag = %PostAuthorizedTag
@onready var post_featured_tag = %PostFeaturedTag
@onready var post_hotted_tag = %PostHottedTag
@onready var title_label = %TitleLabel
@onready var content_label = %ContentLabel

@onready var views = %Views
@onready var replies = %Replies

signal pressed(data: Dictionary)

var data: Dictionary

func set_post_card_id(id: String) -> void:
	details_request.request_completed.connect(on_details_received)
	details_request.request("https://api.codemao.cn/web/forums/posts/%s/details" %id)

func on_details_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		queue_free()
		return

	set_post_card_data(json)

func set_post_card_data(_data: Dictionary) -> void:
	if _data.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[_data.get("error_code", ""), _data.get("error_message", "")])
		return
	data = _data
	if data.is_empty(): return
	var user: Dictionary = data.get("user", {})
	nickname_label.text = user.get("nickname", "ERROR")
	avatar_texture.load_image(user.get("avatar_url", ""), nickname_label.text)
	work_shop_tag.set_work_shop_data(user.get("work_shop_level", 0), \
			user.get("work_shop_name", ""), \
			user.get("subject_id", 0))
	var create_time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(data.get("created_at"))
	create_time.text = "%s/%s/%s" %[create_time_dict.get("year"), \
			create_time_dict.get("month"), \
			create_time_dict.get("day")]

	post_authorized_tag.visible = data.get("is_authorized", false)
	post_featured_tag.visible = data.get("is_featured", false)
	post_hotted_tag.visible = data.get("is_hotted", false)
	title_label.text = data.get("title")
	content_label.text = Application.html_to_text(data.get("content"))

	views.text = str(data.get("n_views", 0))
	replies.text = str(data.get("n_replies", 0))

func _on_gui_input(event) -> void:
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		pressed.emit(data)

func _on_avatar_gui_input(event) -> void:
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		jump_to_user_menu()

func jump_to_user_menu() -> void:
	Application.append_address.emit(data.get("user").get("nickname"), \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": data.get("user", {}).get("id", -1).to_int()})
