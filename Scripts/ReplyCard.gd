extends PanelContainer

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var is_top = %IsTop
@onready var content_label = %ContentLabel
@onready var updated_at = %UpdatedAt

@onready var comment_container = %CommentContainer
@onready var comment_card_container = %CommentCardContainer

signal reply_pressed(id: int, nickname: String)
signal comment_pressed(id: int, parent_id: int, nickname: String)
signal delete_pressed(id: int)
signal comment_delete_pressed(id: int)

const COMMENT_CARD_SCENE = preload("res://Scenes/Forum/CommentCard.tscn")

var data: Dictionary

var menu


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
		comment_card_scene.comment_pressed.connect(_on_comment_card_comment_pressed)
		comment_card_scene.delete_pressed.connect(_on_comment_card_delete_pressed)
	var create_time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(json.get("created_at"))
	updated_at.text = "%s%s%s%s%s%s  %s:%s" %[
		create_time_dict.get("year"), \
		TranslationServer.translate("YEAR_NAME"), \
		create_time_dict.get("month"), \
		TranslationServer.translate("MONTH_NAME"), \
		create_time_dict.get("day"), \
		TranslationServer.translate("DAY_NAME1"), \
		create_time_dict.get("hour"), \
		create_time_dict.get("minute")
		]

func _on_comment_card_comment_pressed(id: int, nickname: String) -> void:
	comment_pressed.emit(data.get("id").to_int(), id, nickname)

func _on_comment_card_delete_pressed(id: int) -> void:
	comment_delete_pressed.emit(id)

func _menu_callback(item_id: int) -> void:
	if item_id == 0:
		reply_pressed.emit(data.get("id").to_int(), data.get("user").get("nickname"))
	elif item_id == 1:
		delete_pressed.emit(data.get("id").to_int())

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

func _on_gui_input(event):
	if event is InputEventMouseButton and \
			event.is_pressed and \
			event.button_index == 2 and \
			event.button_mask == 2:
		if menu != null: NativeMenu.free_menu(menu)
		menu = NativeMenu.create_menu()
		NativeMenu.add_item(menu, TranslationServer.translate("REPLY_NAME"), _menu_callback, Callable(), 0)
		if data.get("user").get("id").to_int() == Application.user_id: NativeMenu.add_item(menu, TranslationServer.translate("DELETE_NAME"), _menu_callback, Callable(), 1)
		NativeMenu.popup(menu, DisplayServer.mouse_get_position())
