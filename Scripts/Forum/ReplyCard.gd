extends PanelContainer

@onready var comments_request = %CommentsRequest

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var drop_down_button = %DropDownButton
@onready var is_top = %IsTop
@onready var rich_content = %RichContent
@onready var updated_at = %UpdatedAt

@onready var comment_container = %CommentContainer
@onready var comment_card_container = %CommentCardContainer
@onready var expand_more_button = %ExpandMoreButton

signal reply_pressed(id: int, nickname: String)
signal comment_pressed(id: int, parent_id: int, nickname: String)
signal delete_pressed(id: int)
signal comment_delete_pressed(id: int)

const LIMIT: int = 10
const CONTENT_LABEL_SCENE = preload("res://Scenes/Forum/ContentLabel.tscn")
const IMAGE_URL_LOADER_SCENE = preload("res://Scenes/ImageUrlLoader.tscn")
const CODE_VIEWER_SCENE = preload("res://Scenes/Forum/CodeViewer.tscn")
const COMMENT_CARD_SCENE = preload("res://Scenes/Forum/CommentCard.tscn")

var data: Dictionary
var page: int

var menu

func set_reply_card_data(json: Dictionary):
	data = json
	var user: Dictionary = json.get("user")
	avatar_texture.load_image(user.get("avatar_url"), user.get("nickname"))
	nickname_label.text = user.get("nickname")
	work_shop_tag.set_work_shop_data(user.get("work_shop_level"), \
			user.get("work_shop_name"), \
			user.get("subject_id"))
	is_top.self_modulate = Color.html(GlobalTheme.top_color)
	is_top.visible = json.get("is_top")
	var reply_popup_item: PopupItem = PopupItem.new()
	reply_popup_item.text = "REPLY_NAME"
	drop_down_button.popup_items.append(reply_popup_item)
	if int(user.get("id")) == Application.user_id:
		var delete_popup_item: PopupItem = PopupItem.new()
		delete_popup_item.text = "DELETE_NAME"
		drop_down_button.popup_items.append(delete_popup_item)
	rich_content.init_contents(json.get("content"))
	var comments: Array
	if json.has("earliest_comments"): comments = json.get("earliest_comments")
	elif json.has("replies"): comments = json.get("replies").get("items")
	comment_container.visible = !comments.is_empty()
	populate_comments(comments)
	expand_more_button.visible = comments.size() < int(json.get("n_comments", 0))
	updated_at.text = Application.format_relative_time(json.get("created_at"))

# 装载评论
func populate_comments(comments: Array, append: bool = false) -> void:
	comment_container.visible = !comments.is_empty()
	if !append:
		for node in comment_card_container.get_children():
			node.queue_free()
	for comment: Dictionary in comments:
		var comment_card_scene = COMMENT_CARD_SCENE.instantiate()
		comment_card_container.add_child(comment_card_scene)
		comment_card_scene.set_comment_card_data(comment)
		comment_card_scene.comment_pressed.connect(_on_comment_card_comment_pressed)
		comment_card_scene.delete_pressed.connect(_on_comment_card_delete_pressed)

func _on_comments_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	populate_comments(json.get("items", []), page > 1)
	expand_more_button.visible = LIMIT * page < int(json.get("total", 0))

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
	Application.append_address.emit(data.get("user").get("nickname"), \
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

func _on_expand_more_button_pressed():
	page += 1
	comments_request.request("https://api.codemao.cn/web/forums/replies/%s/comments?limit=%s&page=%s" %[data.get("id", 0), LIMIT, page])
