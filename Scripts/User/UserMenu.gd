extends Control

@onready var honor_request = %HonorRequest
@onready var work_list_request = %WorkListRequest
@onready var collection_work_list_request = %CollectionWorkListRequest
@onready var basic_request = %BasicRequest

@onready var please_login_first_panel = %PleaseLoginFirstPanel

@onready var cover_texture = %CoverTexture
@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var author_level_tag = %AuthorLevelTag
@onready var work_shop_tag = %WorkShopTag
@onready var description_label = %DescriptionLabel
@onready var id_label = %IDLabel
@onready var details_button = %DetailsButton

@onready var fans_total_label = %FansTotalLabel
@onready var attention_total_label = %AttentionTotalLabel

@onready var view_times_label = %ViewTimesLabel
@onready var begin_separator = %BeginSeparator
@onready var liked_total_label = %LikedTotalLabel
@onready var collected_total_label = %CollectedTotalLabel
@onready var end_separator = %EndSeparator
@onready var re_created_total_label = %ReCreatedTotalLabel

@onready var doing = %Doing
@onready var doing_label = %DoingLabel
@onready var edit_doing_button = %EditDoingButton
@onready var doing_edit = %DoingEdit

@onready var work_card_container = %WorkCardContainer
@onready var collection_work_card_container = %CollectionWorkCardContainer

const WORK_CARD_SCENE = preload("res://Scenes/Work/WorkCard.tscn")

var user_id: int:
	set(value):
		user_id = value
		please_login_first_panel.visible = user_id <= 0
		if user_id > 0:
			honor_request.request("https://api.codemao.cn/creation-tools/v1/user/center/honor?user_id=%s" %user_id, \
					[], HTTPClient.METHOD_GET)

var max_display_number: int
var doing_text: String

func _ready() -> void:
	Application.user_avatar_update.connect(user_avatar_update)

func _process(_delta) -> void:
	max_display_number = floori((size.x - 80) / 162)
	var count: int = 0
	for node in work_card_container.get_children():
		node.visible = count < max_display_number
		count += 1
	count = 0
	for node in collection_work_card_container.get_children():
		node.visible = count < max_display_number
		count += 1

func user_avatar_update() -> void:
	user_id = Application.user_id

func set_data(data: Dictionary):
	user_id = data.get("id", -1)

func on_honor_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	cover_texture.load_image(json.get("user_cover"))
	avatar_texture.load_image(json.get("avatar_url"))
	nickname_label.text = json.get("nickname")
	description_label.text = json.get("user_description")
	author_level_tag.set_author_level_data(json.get("author_level"))
	if json.get("subject_id", 0) == 0:
		work_shop_tag.hide()
	else:
		work_shop_tag.set_work_shop_data(json.get("work_shop_level", 0), \
				json.get("work_shop_name", ""), \
				json.get("subject_id", 0))
		work_shop_tag.show()
	id_label.text = "ID: %s" %int(json.get("user_id"))
	details_button.visible = json.get("user_id") == Application.user_id

	fans_total_label.text = str(int(json.get("fans_total")))
	attention_total_label.text = str(int(json.get("attention_total")))

	view_times_label.text = str(int(json.get("view_times")))
	liked_total_label.text = str(int(json.get("liked_total")))
	collected_total_label.text = str(int(json.get("collected_total")))
	re_created_total_label.text = str(int(json.get("re_created_total")))

	doing_edit.text = json.get("doing")
	edit_doing_button.visible = user_id == Application.user_id

	work_list_request.request("https://api.codemao.cn/creation-tools/v1/user/center/work-list?user_id=%s&offset=1&limit=12" %user_id, \
			[], HTTPClient.METHOD_GET)
	collection_work_list_request.request("https://api.codemao.cn/creation-tools/v1/user/center/collect/list?user_id=%s&offset=1&limit=12" %user_id, \
			[], HTTPClient.METHOD_GET)

func _on_id_copy_button_pressed():
	DisplayServer.clipboard_set(str(user_id))

func _on_edit_doing_button_pressed() -> void:
	var fly_text_edit: Control = Application.get_global_node("FlyTextEdit")
	fly_text_edit.text = doing_edit.text
	fly_text_edit.finish_editing.connect(_on_fly_text_edit_finish_editing)
	fly_text_edit.show_fly_text_edit()

func _on_fly_text_edit_finish_editing(text: String) -> void:
	doing_text = text
	var headers: PackedStringArray
	headers.append(Application.generate_cookie_header())
	headers.append("Content-Type: application/json;charset=UTF-8")
	basic_request.request("https://api.codemao.cn/nemo/v2/user/basic", \
			headers, \
			HTTPClient.METHOD_PUT, \
			'{"doing":"%s"}' %text)
	var fly_text_edit: Control = Application.get_global_node("FlyTextEdit")
	fly_text_edit.disconnect("finish_editing", _on_fly_text_edit_finish_editing)

func _on_basic_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) == OK:
		var json: Dictionary = json_class.data
		if result != HTTPRequest.RESULT_SUCCESS: return
		if json.has("error_code"):
			Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
			return
	else: doing_edit.text = doing_text

func on_work_list_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	var items: Array = json.get("items")
	for item: Dictionary in items:
		var work_card_scene = WORK_CARD_SCENE.instantiate()
		work_card_container.add_child(work_card_scene)
		work_card_scene.user_visible = false
		work_card_scene.set_work_card_data(item)

func on_collection_work_list_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	var items: Array = json.get("items")
	for item: Dictionary in items:
		var work_card_scene = WORK_CARD_SCENE.instantiate()
		collection_work_card_container.add_child(work_card_scene)
		work_card_scene.user_visible = false
		work_card_scene.set_work_card_data(item)

func _on_details_button_pressed():
	Application.append_address.emit(TranslationServer.translate("USER_DETAILS_NAME"), \
			"res://Scenes/User/UserDetailsMenu.tscn", \
			{})

func _on_fans_total_gui_input(event) -> void:
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		Application.append_address.emit(TranslationServer.translate("FANS_NAME"), \
			"res://Scenes/User/Fans&FollowesMenu.tscn", \
			{"id": user_id, "mode": 0})

func _on_followers_total_gui_input(event) -> void:
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		Application.append_address.emit(TranslationServer.translate("ATTENTION_NAME"), \
			"res://Scenes/User/Fans&FollowesMenu.tscn", \
			{"id": user_id, "mode": 1})

func _on_retry_button_pressed():
	user_id = Application.user_id

func _on_login_button_pressed():
	Application.show_login_menu.emit()
