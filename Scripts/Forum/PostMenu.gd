extends Control

@onready var details_request = %DetailsRequest
@onready var repiles_request = %RepilesRequest
@onready var add_reply_request = %AddReplyRequest
@onready var comments_request = %CommentsRequest

@onready var title_label = %TitleLabel
@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var info_container = %InfoContainer
@onready var views = %Views
@onready var replies = %Replies
@onready var to_rich_text_button = %ToRichTextButton
@onready var to_text_button = %ToTextButton
@onready var publish_on = %PublishOn
@onready var rich_content = %RichContent

@onready var all_replies_label = %AllRepliesLabel
@onready var top_reply_card_container = %TopReplyCardContainer
@onready var reply_card_container = %ReplyCardContainer
@onready var pagination_bar = %PaginationBar

@onready var secure_text_edit = %SecureTextEdit

const REPLY_CARD_SCENE = preload("res://Scenes/Forum/ReplyCard.tscn")

var rich_text_enabled: bool = true

var user_id: int
var post_id: int

var details: Dictionary
var repiles: Dictionary

var content: String

func set_data(data: Dictionary):
	post_id = int(data.get("id", 0))
	secure_text_edit.post_id = post_id
	details_request.request("https://api.codemao.cn/web/forums/posts/%s/details" %post_id, \
			[Application.generate_cookie_header()])

func on_details_received(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())

	details = json.duplicate(true)
	var user: Dictionary = json.get("user", {})
	if json.has("error_code"): return
	user_id = user.get("id").to_int()
	repiles_request.request("https://api.codemao.cn/web/forums/posts/%s/replies?page=1&limit=30&sort=-created_at" %json.get("id", 0), \
			[Application.generate_cookie_header()])
	nickname_label.text = user.get("nickname", "ERROR")
	avatar_texture.load_image(user.get("avatar_url"), user.get("nickname", "ERROR"))
	work_shop_tag.set_work_shop_data(user.get("work_shop_level", 0), \
			user.get("work_shop_name", ""), \
			user.get("subject_id", 0))
	title_label.text = json.get("title")
	views.text = str(int(json.get("n_views", 0)))
	replies.text = str(int(json.get("n_replies", 0)) + int(json.get("n_comments", 0)))
	var create_time_dict: Dictionary = Application.adjust_to_beijing_time_from_unix_time(json.get("created_at"))
	publish_on.text = "%s: %s%s%s%s%s%s  %s:%s" %[
		TranslationServer.translate("PUBLISH_ON_NAME"), \
		create_time_dict.get("year"), \
		TranslationServer.translate("YEAR_NAME"), \
		create_time_dict.get("month"), \
		TranslationServer.translate("MONTH_NAME"), \
		create_time_dict.get("day"), \
		TranslationServer.translate("DAY_NAME1"), \
		create_time_dict.get("hour"), \
		create_time_dict.get("minute")
		]
	content = json.get("content")
	rich_content.init_contents(content)

func on_repiles_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	#设置回帖数量和翻页器
	repiles = json.duplicate(true)
	all_replies_label.text = "%s: %s" %[TranslationServer.translate("ALL_REPLIES_NAME"), \
		int(json.get("total"))
	]
	pagination_bar.total = ceili(json.get("total") / 30)
	pagination_bar.visible = pagination_bar.total > 1
	pagination_bar.update_pager_total()

	for node in top_reply_card_container.get_children():
		node.queue_free()
	for node in reply_card_container.get_children():
		node.queue_free()
	var items: Array = json.get("items")
	for item: Dictionary in items:
		var reply_card_scene = REPLY_CARD_SCENE.instantiate()
		if item.get("is_top"): top_reply_card_container.add_child(reply_card_scene)
		else: reply_card_container.add_child(reply_card_scene)
		reply_card_scene.set_reply_card_data(item)
		reply_card_scene.reply_pressed.connect(_on_reply_card_reply_pressed)
		reply_card_scene.comment_pressed.connect(_on_comment_card_comment_pressed)
		reply_card_scene.delete_pressed.connect(_on_reply_card_delete_pressed)
		reply_card_scene.comment_delete_pressed.connect(_on_comment_card_delete_pressed)

func _on_add_reply_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	repiles_request.request("https://api.codemao.cn/web/forums/posts/%s/replies?page=1&limit=30&sort=-created_at" %post_id)
	pagination_bar.current_page = 1
	pagination_bar.update_current_page()

func _on_comments_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var err = JSON.parse_string(body.get_string_from_utf8())
	if err != null:
		var json: Dictionary = err
		if result != HTTPRequest.RESULT_SUCCESS: return
		if json.has("error_code"):
			Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
			return

	repiles_request.request("https://api.codemao.cn/web/forums/posts/%s/replies?page=1&limit=30&sort=-created_at" %post_id)
	pagination_bar.update_current_page()

func _on_avatar_texture_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		jump_to_user_menu()

func _on_nickname_label_pressed():
	jump_to_user_menu()

func jump_to_user_menu():
	Application.append_address.emit(details.get("user").get("nickname"), \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": user_id})

func _on_open_in_browser_button_pressed():
	OS.shell_open("https://shequ.codemao.cn/community/%s" %post_id)

func _on_to_rich_text_button_pressed():
	rich_text_enabled = true
	rich_content.init_contents(content)

func _on_to_text_button_pressed():
	rich_text_enabled = false
	rich_content.init_contents(content)

func _on_mirroring_button_pressed():
	var zip_packer: ZIPPacker = ZIPPacker.new()
	var time_hash: int = Time.get_datetime_dict_from_system(true).hash()
	var error = zip_packer.open("user://Files/%s.zip" %time_hash)
	if error != OK: return
	var details_copy: Dictionary = details.duplicate(true)

	var avatar_url: String = details_copy.get("user").get("avatar_url")
	var avatar_image: Image = avatar_texture.texture.get_image()
	var image_data: PackedByteArray = avatar_image.get_data()
	var save_path: String = "Images/UserAvatar"
	if avatar_url.ends_with(".jpeg") or avatar_url.ends_with(".jpg"): save_path = save_path + ".jpg"
	if avatar_url.ends_with(".png"): save_path = save_path + ".png"
	zip_packer.start_file(save_path)
	zip_packer.write_file(image_data)
	zip_packer.close_file()
	details_copy.get("user")["avatar_url"] = save_path

	zip_packer.start_file("Details.json")
	zip_packer.write_file(JSON.stringify(details, "\t").to_utf8_buffer())
	zip_packer.close_file()

	zip_packer.start_file("Repiles.json")
	zip_packer.write_file(JSON.stringify(repiles, "\t").to_utf8_buffer())
	zip_packer.close_file()

	zip_packer.close()

func _on_reply_card_reply_pressed(id: int, nickname: String) -> void:
	secure_text_edit.set_reply(id, 0, nickname)

func _on_comment_card_comment_pressed(id: int, parent_id: int, nickname: String) -> void:
	secure_text_edit.set_reply(id, parent_id, nickname)

func _on_reply_card_delete_pressed(id: int) -> void:
	comments_request.request("https://api.codemao.cn/web/forums/replies/%s" %id, \
	[Application.generate_cookie_header()], \
	HTTPClient.METHOD_DELETE)

func _on_comment_card_delete_pressed(id: int) -> void:
	comments_request.request("https://api.codemao.cn/web/forums/comments/%s" %id, \
	[Application.generate_cookie_header()], \
	HTTPClient.METHOD_DELETE)

func _on_secure_text_edit_comment(id: int, text: String) -> void:
	var headers: PackedStringArray
	headers.append(Application.generate_cookie_header())
	headers.append("Content-Type: application/json;charset=UTF-8")
	var content_data: Dictionary = {
		"content": text
	}
	var json: String = JSON.stringify(content_data)
	add_reply_request.request("https://api.codemao.cn/web/forums/posts/%s/replies" %id, \
			headers, \
			HTTPClient.METHOD_POST, \
			json)
	secure_text_edit.clear()

func _on_secure_text_edit_reply(reply_id: int, parent_id: int, text: String) -> void:
	var headers: PackedStringArray
	headers.append(Application.generate_cookie_header())
	headers.append("Content-Type: application/json;charset=UTF-8")
	var content_data: Dictionary = {
		"content": text
	}
	content_data["parent_id"] = parent_id
	var json: String = JSON.stringify(content_data)
	comments_request.request("https://api.codemao.cn/web/forums/replies/%s/comments" %reply_id, \
			headers, \
			HTTPClient.METHOD_POST, \
			json)
	secure_text_edit.clear()

func _on_pagination_bar_page_changed(page):
	repiles_request.request("https://api.codemao.cn/web/forums/posts/%s/replies?page=%s&limit=30&sort=-created_at" %[post_id, page])
