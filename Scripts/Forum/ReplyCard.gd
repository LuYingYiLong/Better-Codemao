extends PanelContainer

@onready var avatar_texture = %AvatarTexture
@onready var nickname_label = %NicknameLabel
@onready var work_shop_tag = %WorkShopTag
@onready var drop_down_button = %DropDownButton
@onready var is_top = %IsTop
@onready var contents_container = %ContentsContainer
@onready var updated_at = %UpdatedAt

@onready var comment_container = %CommentContainer
@onready var comment_card_container = %CommentCardContainer

signal reply_pressed(id: int, nickname: String)
signal comment_pressed(id: int, parent_id: int, nickname: String)
signal delete_pressed(id: int)
signal comment_delete_pressed(id: int)

const CONTENT_LABEL_SCENE = preload("res://Scenes/Forum/ContentLabel.tscn")
const IMAGE_URL_LOADER_SCENE = preload("res://Scenes/ImageUrlLoader.tscn")
const CODE_VIEWER_SCENE = preload("res://Scenes/Forum/CodeViewer.tscn")
const COMMENT_CARD_SCENE = preload("res://Scenes/Forum/CommentCard.tscn")

var data: Dictionary
var code_language: String

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
	init_contents(Application.html_to_bbcode(json.get("content")))
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
	updated_at.text = Application.format_relative_time(json.get("created_at"))

func init_contents(content: String) -> void:
	for node in contents_container.get_children():
		node.queue_free()
	var bbcode_content: String = Application.html_to_bbcode(content)
	populate_content(bbcode_content)

func populate_content(bbcode_content: String) -> void:
	var regex = RegEx.new()
	regex.compile("(\\[.+?\\])")

	for result in regex.search_all(bbcode_content):
		var get_string: String = result.get_string()

		if get_string.begins_with("[language=") and get_string.ends_with("]"):
			code_language = get_string.trim_prefix("[language=").trim_suffix("]")
			var pos: int = bbcode_content.find(get_string)
			var result_length: int = get_string.length()
			for i: int in range(result_length):
				bbcode_content[pos] = ""
		elif get_string == "[/language]":
			code_language = ""
			var pos: int = bbcode_content.find(get_string)
			var result_length: int = get_string.length()
			for i: int in range(result_length):
				bbcode_content[pos] = ""

		# 添加图像
		elif get_string.begins_with("[image=") and get_string.ends_with("]"):
			var split: PackedStringArray = bbcode_content.split(get_string)
			var content_label_scene = CONTENT_LABEL_SCENE.instantiate()
			contents_container.add_child(content_label_scene)
			content_label_scene.append_text(split[0])
			
			var image_url_loader = IMAGE_URL_LOADER_SCENE.instantiate()
			contents_container.add_child(image_url_loader)
			image_url_loader.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			image_url_loader.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
			image_url_loader.load_image(get_string.trim_prefix("[image=").trim_suffix("]"))
			
			if split.size() >= 2:
				populate_content(split[1])
				return

		if get_string == "[code]":
			var content_label_scene = CONTENT_LABEL_SCENE.instantiate()
			var code_viewer_scene = CODE_VIEWER_SCENE.instantiate()
			var split: PackedStringArray = bbcode_content.split("[code]")
			split.append(split[1].get_slice("[/code]", 1))
			split.set(1, split[1].get_slice("[/code]", 0))
			
			contents_container.add_child(content_label_scene)
			content_label_scene.append_text(split[0])
			
			contents_container.add_child(code_viewer_scene)
			code_viewer_scene.text = split[1]
			code_viewer_scene.type = code_language
			if split.size() >= 3: populate_content(split[2])
			return

	var content_label_scene = CONTENT_LABEL_SCENE.instantiate()
	contents_container.add_child(content_label_scene)
	content_label_scene.append_text(bbcode_content)

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
