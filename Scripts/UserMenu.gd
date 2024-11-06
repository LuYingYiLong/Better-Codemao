extends Control

@onready var honor_request = %HonorRequest
@onready var user_cover_request = %UserCoverRequest
@onready var avatar_request = %AvatarRequest
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

const WORK_CARD_SCENE = preload("res://Scenes/WorkCard.tscn")

var user_id: int:
	set(value):
		user_id = value
		if not honor_request.is_connected("request_completed", on_honor_received):
			honor_request.request_completed.connect(on_honor_received)
		honor_request.request("https://api.codemao.cn/creation-tools/v1/user/center/honor?user_id=%s" %user_id, \
				[], HTTPClient.METHOD_GET)

var avatar_thread_helper: ThreadHelper
var cover_thread_helper: ThreadHelper

func _ready():
	user_cover_request.request_completed.connect(on_user_cover_received)
	avatar_request.request_completed.connect(on_avatar_received)
	work_list_request.request_completed.connect(on_work_list_received)
	collection_work_list_request.request_completed.connect(on_collection_work_list_received)
	avatar_thread_helper = ThreadHelper.new(self)
	cover_thread_helper = ThreadHelper.new(self)

func set_data(data: Dictionary):
	user_id = data.get("id", -1)

func on_honor_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	user_cover_request.request(json.get("user_cover"))
	avatar_request.request(json.get("avatar_url"))
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

	work_list_request.request("https://api.codemao.cn/creation-tools/v1/user/center/work-list?user_id=%s&offset=1&limit=6" %user_id, \
			[], HTTPClient.METHOD_GET)
	collection_work_list_request.request("https://api.codemao.cn/creation-tools/v1/user/center/collect/list?user_id=%s&offset=1&limit=6" %user_id, \
			[], HTTPClient.METHOD_GET)

func on_avatar_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	else:
		avatar_thread_helper.join_function(func(): load_avatar_texture_from_thread(body))
		avatar_thread_helper.start()

func load_avatar_texture_from_thread(buffer: PackedByteArray):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(buffer)
	if error != OK:
		error = image.load_png_from_buffer(buffer)

	var texture = ImageTexture.create_from_image(image)
	avatar_texture.call_deferred("set_texture", texture)

func on_user_cover_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	else:
		cover_thread_helper.join_function(func(): load_cover_texture_from_thread(body))
		cover_thread_helper.start()

func load_cover_texture_from_thread(buffer: PackedByteArray):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(buffer)
	if error != OK:
		error = image.load_png_from_buffer(buffer)

	var texture = ImageTexture.create_from_image(image)
	cover_texture.call_deferred("set_texture", texture)

func on_work_list_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var items: Array = json.get("items")
	for item: Dictionary in items:
		var work_card_scene = WORK_CARD_SCENE.instantiate()
		work_card_container.add_child(work_card_scene)
		work_card_scene.set_work_card_data(item)

func on_collection_work_list_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var items: Array = json.get("items")
	for item: Dictionary in items:
		var work_card_scene = WORK_CARD_SCENE.instantiate()
		collection_work_card_container.add_child(work_card_scene)
		work_card_scene.set_work_card_data(item)

func _on_details_button_pressed():
	Application.append_address.emit(TranslationServer.translate("USER_DETAILS_NAME"), \
			"res://Scenes/UserDetailsMenu.tscn", \
			{})
