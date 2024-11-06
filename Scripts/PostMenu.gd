extends Control

@onready var details_request = %DetailsRequest
@onready var avatar_request = %AvatarRequest
@onready var repiles_request = %RepilesRequest

@onready var title_label = %TitleLabel
@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var content_label = %ContentLabel

@onready var all_replies_label = %AllRepliesLabel
@onready var top_reply_card_container = %TopReplyCardContainer
@onready var reply_card_container = %ReplyCardContainer

const REPLY_CARD_SCENE = preload("res://Scenes/ReplyCard.tscn")

var user_id: int
var post_id: int

var thread_helper: ThreadHelper

func _ready():
	avatar_request.request_completed.connect(on_avatar_received)
	repiles_request.request_completed.connect(on_repiles_received)
	thread_helper = ThreadHelper.new(self)

func set_data(data: Dictionary):
	details_request.request_completed.connect(on_details_received)
	post_id = int(data.get("id"))
	details_request.request("https://api.codemao.cn/web/forums/posts/%s/details" %post_id)

func on_details_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Could not get data")
		queue_free()
		return

	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var user: Dictionary = json.get("user", {})
	user_id = user.get("id").to_int()
	repiles_request.request("https://api.codemao.cn/web/forums/posts/%s/replies?page=1&limit=10&sort=-created_at" %json.get("id", 0))
	nickname_label.text = user.get("nickname", "ERROR")
	avatar_request.request(user.get("avatar_url"))
	work_shop_tag.set_work_shop_data(user.get("work_shop_level", 0), \
			user.get("work_shop_name", ""), \
			user.get("subject_id", 0))
	title_label.text = json.get("title")
	content_label.clear()
	content_label.append_text(Application.html_to_bbcode(json.get("content")))

func on_avatar_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		avatar_texture.hide()
		push_error("Could not get data")
	else:
		thread_helper.join_function(func(): load_avatar_texture_from_thread(body))
		thread_helper.start()

func load_avatar_texture_from_thread(buffer: PackedByteArray):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(buffer)
	if error != OK:
		error = image.load_png_from_buffer(buffer)

	var texture = ImageTexture.create_from_image(image)
	avatar_texture.call_deferred("set_texture", texture)
	avatar_texture.call_deferred("set_visible", true)

func on_repiles_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	all_replies_label.text = "%s: %s" %[TranslationServer.translate("ALL_REPLIES_NAME"), \
		json.get("total")
	]
	var items: Array = json.get("items")
	for item: Dictionary in items:
		var reply_card_scene = REPLY_CARD_SCENE.instantiate()
		if item.get("is_top"): top_reply_card_container.add_child(reply_card_scene)
		else: reply_card_container.add_child(reply_card_scene)
		reply_card_scene.set_reply_card_data(item)
		#print(item)
		#print("\n")

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
			"res://Scenes/UserMenu.tscn", \
			{"id": user_id})

func _on_open_in_browser_button_pressed():
	OS.shell_open("https://shequ.codemao.cn/community/%s" %post_id)
