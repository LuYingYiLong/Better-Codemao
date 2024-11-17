extends PanelContainer

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var content_label = %ContentLabel

var data: Dictionary

func set_comment_card_data(json: Dictionary):
	data = json
	var user: Dictionary
	if json.has("user"): user = json.get("user")
	elif json.has("reply_user"): user = json.get("reply_user")
	avatar_texture.load_image(user.get("avatar_url"))
	nickname_label.text = user.get("nickname")
	work_shop_tag.set_work_shop_data(user.get("work_shop_level"), \
			user.get("work_shop_name"), \
			user.get("subject_id"))
	content_label.text = json.get("content")

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
			{"id": data.get("user", {}).get("id", -1).to_int()})
