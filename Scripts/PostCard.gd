extends PanelContainer

@onready var details_request = %DetailsRequest
@onready var avatar_request = %AvatarRequest

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var title_label = %TitleLabel
@onready var content_label = %ContentLabel

signal pressed(data: Dictionary)

var data: Dictionary

var thread_helper: ThreadHelper

func _ready():
	avatar_request.request_completed.connect(on_avatar_received)
	thread_helper = ThreadHelper.new(self)

func set_post_card_id(id: String):
	details_request.request_completed.connect(on_details_received)
	details_request.request("https://api.codemao.cn/web/forums/posts/%s/details" %id)

func on_details_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Could not get data")
		queue_free()
		return

	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	set_post_card_data(json)

func set_post_card_data(_data: Dictionary):
	data = _data
	var user: Dictionary = data.get("user", {})
	nickname_label.text = user.get("nickname", "ERROR")
	avatar_request.request(user.get("avatar_url"))
	work_shop_tag.set_work_shop_data(user.get("work_shop_level", 0), \
			user.get("work_shop_name", ""), \
			user.get("subject_id", 0))
	title_label.text = data.get("title")
	content_label.text = data.get("content")

func on_avatar_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: push_error("Could not get data")
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
			"res://Scenes/UserMenu.tscn", \
			{"id": data.get("user", {}).get("id", -1).to_int()})
