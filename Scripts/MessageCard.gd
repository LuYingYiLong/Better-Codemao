extends PanelContainer

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var link_button = %LinkButton
@onready var content_label = %ContentLabel
@onready var comment_panel = %CommentPanel
@onready var comment_label = %CommentLabel

var data: Dictionary
var type: String

var user_id: int
var post_id: int
var subject_id: int
	
func set_message_card_data(_data: Dictionary):
	data = _data
	type = data.get("type")
	var content = JSON.parse_string(data.get("content").replace("\\", ""))
	if content == null:
		queue_free()
		return
	var sender: Dictionary = content.get("sender")
	var message: Dictionary = content.get("message", {})
	var link_button_text: String = TranslationServer.translate("%s_NAME" %type)
	var content_label_text: String
	var comment_label_text: String
	if type == "POST_COMMENT" or type == "WORK_COMMENT":
		link_button.text = link_button_text.format([message.get("business_name")])
		content_label_text = message.get("comment")
	elif type == "WORK_REPLY_AUTHOR" or type == "POST_REPLY_AUTHOR" or type == "WORK_REPLY_REPLY_AUTHOR":
		link_button.text = link_button_text.format([message.get("business_name"), message.get("replied_user_nickname")])
		content_label_text = message.get("reply")
		comment_label_text = message.get("replied", "")
	elif type == "WORK_REPLY_REPLY" or type == "POST_REPLY":
		link_button.text = link_button_text.format([message.get("business_name")])
		content_label_text = message.get("reply")
		comment_label_text = message.get("replied", "")
	elif type == "WORK_LIKE":
		link_button.text = link_button_text.format([message.get("business_name")])
	elif type == "WORK_FORK":
		link_button.text = link_button_text.format([message.get("business_name")])
	elif type == "WORK_SHOP_USER_LEAVE":
		link_button.text = link_button_text.format([content.get("leaver").get("nickname"), \
				content.get("content").get("work_subject_name")])
		user_id = content.get("leaver").get("leaver_id")
		subject_id = content.get("content").get("subject_id")
	elif "POST_DELETE":
		link_button.text = link_button_text.format([message.get("business_name"), \
				message.get("reason_name"), \
				message.get("result_name")])
	else: Application.add_system_message.emit("Unknow type: %s" %type, GlobalTheme.system_warning_message_color, 4)
	user_id = sender.get("id", 0)
	post_id = message.get("business_id", 0)
	content_label.text = Application.html_to_text(content_label_text)
	comment_label.text = Application.html_to_text(comment_label_text).strip_escapes()
	content_label.visible = !content_label.text.is_empty()
	comment_panel.visible = !comment_label.text.is_empty()
	nickname_label.text = sender.get("nickname")
	avatar_texture.load_image(sender.get("avatar_url"))

func _on_avatar_texture_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_mask == 1 and \
			event.button_index == 1:
		jump_to_user_menu()

func _on_nickname_label_pressed():
	jump_to_user_menu()

func jump_to_user_menu():
	if user_id == 0: return
	Application.append_address.emit(TranslationServer.translate("USER_NAME"), \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": user_id})

func _on_link_button_pressed():
	if type == "POST_COMMENT" or \
			type == "POST_REPLY_AUTHOR" or \
			type == "POST_REPLY":
		if post_id == 0: return
		Application.append_address.emit(TranslationServer.translate("POST_NAME"), \
			"res://Scenes/Forum/PostMenu.tscn", \
			{"id": post_id})