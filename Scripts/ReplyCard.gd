extends PanelContainer

@onready var avatar_request = %AvatarRequest

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var is_top = %IsTop
@onready var content_label = %ContentLabel

@onready var comment_container = %CommentContainer
@onready var comment_card_container = %CommentCardContainer

const COMMENT_CARD_SCENE = preload("res://Scenes/CommentCard.tscn")

var data: Dictionary

var thread_helper: ThreadHelper

func _ready():
	avatar_request.request_completed.connect(on_avatar_received)
	thread_helper = ThreadHelper.new(self)

func set_reply_card_data(json: Dictionary):
	data = json
	var user: Dictionary = json.get("user")
	avatar_request.request(user.get("avatar_url"))
	nickname_label.text = user.get("nickname")
	work_shop_tag.set_work_shop_data(user.get("work_shop_level"), \
			user.get("work_shop_name"), \
			user.get("subject_id"))
	is_top.self_modulate = Color.html(GlobalTheme.top_color)
	is_top.visible = json.get("is_top")
	content_label.text = Application.html_to_bbcode(json.get("content"))
	var earliest_comments: Array = json.get("earliest_comments")
	comment_container.visible = earliest_comments.size() > 0
	for comment: Dictionary in earliest_comments:
		var comment_card_scene = COMMENT_CARD_SCENE.instantiate()
		comment_card_container.add_child(comment_card_scene)
		comment_card_scene.set_comment_card_data(comment)

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
			{"id": data.get("user", {}).get("id", -1).to_int()})
