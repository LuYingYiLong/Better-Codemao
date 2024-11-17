extends PanelContainer

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var is_top = %IsTop
@onready var content_label = %ContentLabel

@onready var comment_container = %CommentContainer
@onready var comment_card_container = %CommentCardContainer

const COMMENT_CARD_SCENE = preload("res://Scenes/Forum/CommentCard.tscn")

var data: Dictionary

func set_reply_card_data(json: Dictionary):
	data = json
	var user: Dictionary = json.get("user")
	avatar_texture.load_image(user.get("avatar_url"))
	nickname_label.text = user.get("nickname")
	work_shop_tag.set_work_shop_data(user.get("work_shop_level"), \
			user.get("work_shop_name"), \
			user.get("subject_id"))
	is_top.self_modulate = Color.html(GlobalTheme.top_color)
	is_top.visible = json.get("is_top")
	content_label.text = Application.html_to_text(json.get("content"))
	var earliest_comments: Array
	if json.has("earliest_comments"): earliest_comments = json.get("earliest_comments")
	elif json.has("replies"): earliest_comments = json.get("replies").get("items")
	comment_container.visible = !earliest_comments.is_empty()
	for comment: Dictionary in earliest_comments:
		var comment_card_scene = COMMENT_CARD_SCENE.instantiate()
		comment_card_container.add_child(comment_card_scene)
		comment_card_scene.set_comment_card_data(comment)

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
			"res://Scenes/User/UserMenu.tscn", \
			{"id": int(data.get("user", {}).get("id", -1))})
