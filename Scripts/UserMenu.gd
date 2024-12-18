extends Control

@onready var honor_request = %HonorRequest
@onready var work_list_request = %WorkListRequest
@onready var collection_work_list_request = %CollectionWorkListRequest

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
@onready var liked_total_label = %LikedTotalLabel
@onready var collected_total_label = %CollectedTotalLabel
@onready var re_created_total_label = %ReCreatedTotalLabel

@onready var doing = %Doing

@onready var work_card_container = %WorkCardContainer
@onready var collection_work_card_container = %CollectionWorkCardContainer

const WORK_CARD_SCENE = preload("res://Scenes/Work/WorkCard.tscn")

var user_id: int:
	set(value):
		user_id = value
		if not honor_request.is_connected("request_completed", on_honor_received):
			honor_request.request_completed.connect(on_honor_received)
		honor_request.request("https://api.codemao.cn/creation-tools/v1/user/center/honor?user_id=%s" %user_id, \
				[], HTTPClient.METHOD_GET)

func _ready():
	work_list_request.request_completed.connect(on_work_list_received)
	collection_work_list_request.request_completed.connect(on_collection_work_list_received)

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
	id_label.text = "ID: %s" %json.get("user_id")
	details_button.visible = json.get("user_id") == Application.user_id

	fans_total_label.text = str(json.get("fans_total"))
	attention_total_label.text = str(json.get("attention_total"))

	view_times_label.text = str(json.get("view_times"))
	liked_total_label.text = str(json.get("liked_total"))
	collected_total_label.text = str(json.get("collected_total"))
	re_created_total_label.text = str(json.get("re_created_total"))

	doing.text = json.get("doing")

	work_list_request.request("https://api.codemao.cn/creation-tools/v1/user/center/work-list?user_id=%s&offset=1&limit=12" %user_id, \
			[], HTTPClient.METHOD_GET)
	collection_work_list_request.request("https://api.codemao.cn/creation-tools/v1/user/center/collect/list?user_id=%s&offset=1&limit=12" %user_id, \
			[], HTTPClient.METHOD_GET)

func on_work_list_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	var items: Array = json.get("items")
	for item: Dictionary in items:
		var work_card_scene = WORK_CARD_SCENE.instantiate()
		work_card_container.add_child(work_card_scene)
		work_card_scene.set_work_card_data(item)

func on_collection_work_list_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	var items: Array = json.get("items")
	for item: Dictionary in items:
		var work_card_scene = WORK_CARD_SCENE.instantiate()
		collection_work_card_container.add_child(work_card_scene)
		work_card_scene.set_work_card_data(item)

func _on_details_button_pressed():
	Application.append_address.emit(TranslationServer.translate("USER_DETAILS_NAME"), \
			"res://Scenes/User/UserDetailsMenu.tscn", \
			{})
