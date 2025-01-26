extends Control

@onready var work_request = %WorkRequest
@onready var like_request = %LikeRequest
@onready var collection_request = %CollectionRequest
@onready var comments_request = %CommentsRequest
@onready var follow_request = %FollowRequest
@onready var user_works_request = %UserWorksRequest
@onready var recommended_request = %RecommendedRequest

@onready var preview_texture = %PreviewTexture

@onready var like_icon = %LikeIcon
@onready var like_label = %LikeLabel
@onready var praise_times = %PraiseTimes
@onready var like_button = %LikeButton
@onready var liked_button = %LikedButton
@onready var collect_icon = %CollectIcon
@onready var collect_label = %CollectLabel
@onready var collect_times = %CollectTimes
@onready var collect_button = %CollectButton
@onready var collected_button = %CollectedButton

@onready var all_replies_label = %AllRepliesLabel
@onready var top_reply_card_container = %TopReplyCardContainer
@onready var reply_card_container = %ReplyCardContainer
@onready var pagination_bar = %PaginationBar

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var author_level_tag = %AuthorLevelTag
@onready var follow_button = %FollowButton
@onready var followed_button = %FollowedButton

@onready var work_name_label = %WorkNameLabel
@onready var description = %Description
@onready var operation_label = %OperationLabel
@onready var operation = %Operation
@onready var work_tag_label = %WorkTagLabel
@onready var work_tag_container = %WorkTagContainer
@onready var view_times = %ViewTimes
@onready var publish_time = %PublishTime

@onready var h_work_card_container = %HWorkCardContainer

@onready var h_recommended_work_card_container = %HRecommendedWorkCardContainer

const LIKE_TEXTURE: Texture = preload("res://Resources/Textures/Like.svg")
const LIKED_TEXTURE: Texture = preload("res://Resources/Textures/Liked.svg")
const STAR_TEXTURE: Texture = preload("res://Resources/Textures/Star.svg")
const STARRED_TEXTURE: Texture = preload("res://Resources/Textures/Starred.svg")

const MAX_LIMIT: int = 40

const REPLY_CARD_SCENE = preload("res://Scenes/Forum/ReplyCard.tscn")

const WORK_TAG_SCENE = preload("res://Scenes/Work/WorkTag.tscn")
const H_WORK_CARD_SCENE = preload("res://Scenes/Work/HWorkCard.tscn")

var work_id: int:
	set(value):
		work_id = value
		work_request.request("https://api.codemao.cn/creation-tools/v1/works/%s" %work_id, \
				[Application.generate_cookie_header()])
var user_id: int

var is_praised: bool
var is_collected: bool

var offset: int
var limit: int = 10

func _process(_delta):
	preview_texture.custom_minimum_size.y = (preview_texture.size.x / 16 ) * 10

func set_data(data: Dictionary):
	work_id = data.get("id", 0)

func _on_work_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	preview_texture.load_image(json.get("preview"))

	var abilities: Dictionary = json.get("abilities")
	is_praised = abilities.get("is_praised")
	is_collected = abilities.get("is_collected")
	update_like_collect_data()
	praise_times.text = str(int(json.get("praise_times")))
	collect_times.text = str(int(json.get("collect_times")))

	comments_request.request("https://api.codemao.cn/creation-tools/v1/works/%s/comments?offset=%s&limit=%s" %[work_id, offset, limit])
	all_replies_label.text = "%s: %s" %[TranslationServer.translate("ALL_REPLIES_NAME"), \
		json.get("comment_times")
	]
	pagination_bar.total = round(json.get("comment_times") / 10)
	pagination_bar.update_pager_total()

	var user_info: Dictionary = json.get("user_info")
	user_id = user_info.get("id")
	avatar_texture.load_image(user_info.get("avatar"))
	nickname_label.text = user_info.get("nickname")
	author_level_tag.set_author_level_data(user_info.get("author_level"))
	follow_button.visible = !user_info.get("fork_user") and user_id != Application.user_id
	followed_button.visible = user_info.get("fork_user") and user_id != Application.user_id

	work_name_label.text = json.get("work_name")
	description.text = json.get("description")
	var operation_string: String = json.get("operation")
	operation_label.visible = !operation_string.is_empty()
	operation.visible = !operation_string.is_empty()
	operation.text = operation_string
	work_tag_label.visible = !json.get("work_label_list").is_empty()
	work_tag_container.visible = !json.get("work_label_list").is_empty()
	for node in work_tag_container.get_children():
		node.queue_free()
	for work_tag: Dictionary in json.get("work_label_list"):
		var work_tag_scene = WORK_TAG_SCENE.instantiate()
		work_tag_container.add_child(work_tag_scene)
		work_tag_scene.set_work_tag_data(work_tag)
	view_times.text = str(json.get("view_times"))
	var publish_time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(json.get("publish_time"))
	publish_time.text = "%s%s%s%s%s%s" %[
		publish_time_dict.get("year"), \
		TranslationServer.translate("YEAR_NAME"), \
		publish_time_dict.get("month"), \
		TranslationServer.translate("MONTH_NAME"), \
		publish_time_dict.get("day"), \
		TranslationServer.translate("DAY_NAME1")
	]

	if user_id == 0: return
	user_works_request.request("https://api.codemao.cn/web/works/users/%s" %user_id)
	recommended_request.request("https://api.codemao.cn/nemo/v2/works/web/%s/recommended" %user_id)

func _on_open_in_browser_button_pressed():
	OS.shell_open("https://shequ.codemao.cn/work/%s" %work_id)

func _on_like_button_pressed():
	like_request.request("https://api.codemao.cn/nemo/v2/works/%s/like" %work_id, \
			[Application.generate_cookie_header()], \
			HTTPClient.METHOD_POST)
	like_button.disabled = true
	liked_button.disabled = true

func _on_collect_button_pressed():
	collection_request.request("https://api.codemao.cn/nemo/v2/works/%s/collection" %work_id, \
			[Application.generate_cookie_header()], \
			HTTPClient.METHOD_POST)
	collect_button.disabled = true
	collected_button.disabled = true

func _on_liked_button_pressed():
	like_request.request("https://api.codemao.cn/nemo/v2/works/%s/like" %work_id, \
			[Application.generate_cookie_header()], \
			HTTPClient.METHOD_DELETE)
	like_button.disabled = true
	liked_button.disabled = true

func _on_collected_button_pressed():
	collection_request.request("https://api.codemao.cn/nemo/v2/works/%s/collection" %work_id, \
			[Application.generate_cookie_header()], \
			HTTPClient.METHOD_DELETE)
	collect_button.disabled = true
	collected_button.disabled = true

func _on_like_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS and body.get_string_from_utf8().is_empty(): return
	is_praised = not is_praised
	update_like_collect_data()
	like_button.visible = !is_praised
	liked_button.visible = is_praised
	like_button.disabled = false
	liked_button.disabled = false

func _on_collection_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS and body.get_string_from_utf8().is_empty(): return
	is_collected = not is_collected
	update_like_collect_data()
	collect_button.visible = !is_collected
	collected_button.visible = is_collected
	collect_button.disabled = false
	collected_button.disabled = false

func update_like_collect_data():
	if is_praised:
		like_icon.texture = LIKED_TEXTURE
		like_label.text = TranslationServer.translate("LIKED_NAME")
	else:
		like_icon.texture = LIKE_TEXTURE
		like_label.text = TranslationServer.translate("LIKE_NAME")
	if is_collected:
		collect_icon.texture = STARRED_TEXTURE
		collect_label.text = TranslationServer.translate("COLLECTED_NAME")
	else:
		collect_icon.texture = STAR_TEXTURE
		collect_label.text = TranslationServer.translate("COLLECT_NAME")

func _on_comments_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	for node in top_reply_card_container.get_children():
		node.queue_free()
	for node in reply_card_container.get_children():
		node.queue_free()
	var items: Array = json.get("items")
	for _i in range(clampi(limit - 10, 0, 9999)):
		items.remove_at(0)
	for item: Dictionary in items:
		var reply_card_scene = REPLY_CARD_SCENE.instantiate()
		if item.get("is_top"): top_reply_card_container.add_child(reply_card_scene)
		else: reply_card_container.add_child(reply_card_scene)
		reply_card_scene.set_reply_card_data(item)

func _on_pagination_bar_page_changed(page: int):
	if page <= 0: return
	limit = page * 10
	if limit > MAX_LIMIT:
		offset = limit - MAX_LIMIT
		limit = MAX_LIMIT
	else: offset = 0
	comments_request.request("https://api.codemao.cn/creation-tools/v1/works/%s/comments?offset=%s&limit=%s" %[work_id, offset, limit])

func view_user():
	if user_id == 0: return
	Application.append_address.emit(nickname_label.text, \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": user_id})

func _on_follow_button_pressed():
	if user_id == 0: return
	follow_request.request("https://api.codemao.cn/nemo/v2/user/%s/follow" %user_id, \
				[Application.generate_cookie_header()], \
				HTTPClient.METHOD_POST)
	follow_button.disabled = true

func _on_followed_button_pressed():
	if user_id == 0: return
	follow_request.request("https://api.codemao.cn/nemo/v2/user/%s/follow" %user_id, \
				[Application.generate_cookie_header()], \
				HTTPClient.METHOD_DELETE)
	followed_button.disabled = true

func _on_follow_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS and body.get_string_from_utf8().is_empty(): return
	follow_button.disabled = false
	followed_button.disabled = false
	follow_button.visible = not follow_button.visible
	followed_button.visible = not followed_button.visible

func _on_user_works_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	for node in h_work_card_container.get_children():
		node.queue_free()
	for item: Dictionary in json.get("items"):
		var h_work_card_scene = H_WORK_CARD_SCENE.instantiate()
		h_work_card_container.add_child(h_work_card_scene)
		h_work_card_scene.set_work_card_data(item)

func _on_recommended_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string('{"items":%s}' %body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	for node in h_recommended_work_card_container.get_children():
		node.queue_free()
	for item: Dictionary in json.get("items"):
		var h_work_card_scene = H_WORK_CARD_SCENE.instantiate()
		h_recommended_work_card_container.add_child(h_work_card_scene)
		h_work_card_scene.set_work_card_data(item)
