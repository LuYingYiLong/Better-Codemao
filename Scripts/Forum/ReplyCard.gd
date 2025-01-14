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

var menu

func _ready() -> void:
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

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
	populate_content(Application.html_to_bbcode(json.get("content")))
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
func populate_content(content: String):
	for node in contents_container.get_children():
		node.queue_free()
	var content_array: PackedStringArray = Application.html_to_bbcode(content).split("|SPLIT|")
	for content_type: String in content_array:
		if content_type.contains("https://cdn-community.bcmcdn.com/47/community/"):
			var image_url_loader = IMAGE_URL_LOADER_SCENE.instantiate()
			contents_container.add_child(image_url_loader)
			image_url_loader.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
			image_url_loader.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			image_url_loader.load_image(content_type)
		elif content_type.contains("|CODE|"):
			var split: PackedStringArray = content_type.split("|CODE|")
			for _content: String in split:
				if _content.is_empty(): continue
				elif _content.begins_with("|BEGIN|") and _content.ends_with("|END|"):
					var code_viewer_scene = load("res://Scenes/Forum/CodeViewer.tscn").instantiate()
					contents_container.add_child(code_viewer_scene)
					code_viewer_scene.text = _content.trim_prefix("|BEGIN|").trim_suffix("|END|")
					code_viewer_scene.type = ""
				else:
					var content_label = CONTENT_LABEL_SCENE.instantiate()
					contents_container.add_child(content_label)
					content_label.append_text(content_type)
		else:
			var content_label = CONTENT_LABEL_SCENE.instantiate()
			contents_container.add_child(content_label)
			content_label.append_text(content_type)

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

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0:
		add_theme_stylebox_override("panel", load("res://Resources/Themes/DefaultPanelStyle.tres"))
		nickname_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		nickname_label.add_theme_color_override("font_focus_color", Color.html(GlobalTheme.light_mode_font_color))
		nickname_label.add_theme_color_override("font_hover_color", Color.html(GlobalTheme.light_mode_font_color))
		nickname_label.add_theme_color_override("font_hover_pressed_color", Color.html(GlobalTheme.light_mode_font_color))
		nickname_label.add_theme_color_override("font_pressed_color", Color.html(GlobalTheme.light_mode_font_color))
		updated_at.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
	else:
		add_theme_stylebox_override("panel", load("res://Resources/Themes/DefaultPanelDarknessStyle.tres"))
		nickname_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		nickname_label.add_theme_color_override("font_focus_color", Color.html(GlobalTheme.dark_mode_font_color))
		nickname_label.add_theme_color_override("font_hover_color", Color.html(GlobalTheme.dark_mode_font_color))
		nickname_label.add_theme_color_override("font_hover_pressed_color", Color.html(GlobalTheme.dark_mode_font_color))
		nickname_label.add_theme_color_override("font_pressed_color", Color.html(GlobalTheme.dark_mode_font_color))
		updated_at.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
