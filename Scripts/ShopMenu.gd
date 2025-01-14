extends Control

@onready var shop_request = %ShopRequest
@onready var works_request = %WorksRequest
@onready var forum_request = %ForumRequest
@onready var member_request = %MemberRequest
@onready var comments_request = %CommentsRequest

@onready var scroll_container = %ScrollContainer

@onready var preview_texture = %PreviewTexture
@onready var name_label = %NameLabel
@onready var level_tag = %LevelTag
@onready var level_label = %LevelLabel
@onready var description_label = %DescriptionLabel
@onready var total_score_label = %TotalScoreLabel

@onready var submitted_works = %SubmittedWorks
@onready var work_card_container = %WorkCardContainer
@onready var submitted_works_pagination_bar = %SubmittedWorksPaginationBar

@onready var forum = %Forum
@onready var post_card_container = %PostCardContainer
@onready var forum_pagination_bar = %ForumPaginationBar

@onready var member = %Member
@onready var member_total_label = %MemberTotalLabel
@onready var member_card_container = %MemberCardContainer
@onready var member_pagination_bar = %MemberPaginationBar

@onready var comments_total_label = %CommentsTotalLabel
@onready var reply_card_container = %ReplyCardContainer
@onready var comments_pagination_bar = %CommentsPaginationBar

const WORK_CARD_SCENE = preload("res://Scenes/Work/WorkCard.tscn")
const POST_CARD_SCENE = preload("res://Scenes/Forum/PostCard.tscn")
const MEMBER_CARD_SCENE = preload("res://Scenes/Workshop/MemberCard.tscn")
const REPLY_CARD_SCENE = preload("res://Scenes/Forum/ReplyCard.tscn")
const LOADS_NUMBER: int = 40
const MEMBER_CARD_LOADS_NUMBER: int = 45
const COMMENTS_LOADS_NUMBER: int = 20

var id: int

func _ready() -> void:
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func _process(_delta) -> void:
	work_card_container.columns = clampi(floori(scroll_container.size.x / 155), 1, 999)

func set_data(data: Dictionary) -> void:
	id = data.get("id", 0)
	shop_request.request("https://api.codemao.cn/web/shops/%s" %id)
	works_request.request("https://api.codemao.cn/web/works/subjects/%s/works?&offset=0&limit=%s&sort=-created_at,-id&user_id=%s&work_subject_id=%s" %[id, LOADS_NUMBER, Application.user_id, id])
	comments_request.request("https://api.codemao.cn/web/discussions/%s/comments?source=WORK_SHOP&sort=-created_at&limit=%s&offset=0" %[id, COMMENTS_LOADS_NUMBER])

func _on_shop_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	
	preview_texture.load_image(json.get("preview_url"))
	name_label.text = json.get("name")
	description_label.text = json.get("description")
	var level: int = json.get("level")
	level_label.text = str(level)
	match level:
		0: level_tag.self_modulate = Color.html(GlobalTheme.work_shop_level_0_tag_color)
		1: level_tag.self_modulate = Color.html(GlobalTheme.work_shop_level_1_tag_color)
		2: level_tag.self_modulate = Color.html(GlobalTheme.work_shop_level_2_tag_color)
		3: level_tag.self_modulate = Color.html(GlobalTheme.work_shop_level_3_tag_color)
		4: level_tag.self_modulate = Color.html(GlobalTheme.work_shop_level_4_tag_color)
	
	total_score_label.text = "%s: %s" %[TranslationServer.translate("TOTAL_SCORE_NAME"), \
			json.get("total_score")]

func _on_works_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	
	submitted_works_pagination_bar.total = ceili(float(json.get("total")) / LOADS_NUMBER)
	submitted_works_pagination_bar.update_pager_total()
	submitted_works_pagination_bar.visible = submitted_works_pagination_bar.total > 0
	var items: Array = json.get("items")
	for node in work_card_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		var work_card_scene = WORK_CARD_SCENE.instantiate()
		work_card_container.add_child(work_card_scene)
		work_card_scene.description_visible = false
		work_card_scene.set_work_card_data(item)

func _on_forum_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	forum_pagination_bar.total = ceili(float(json.get("total")) / LOADS_NUMBER)
	forum_pagination_bar.update_pager_total()
	forum_pagination_bar.visible = forum_pagination_bar.total > 0
	var items: Array = json.get("items")
	for node in post_card_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		var post_card_scene = POST_CARD_SCENE.instantiate()
		post_card_container.add_child(post_card_scene)
		post_card_scene.set_post_card_data(item)
		post_card_scene.pressed.connect(on_post_card_scene_pressed)

# 粘贴于ForumMenu
func on_post_card_scene_pressed(data: Dictionary) -> void:
	var forum_history: Dictionary = Application.load_json_file(Application.FORUM_HISTORY_PATH)
	var items: Array = forum_history.get("items", [])
	items.insert(0, data)
	#检查items是否有和该帖子ID相匹配的item，若有则删除
	if items.size() >= 2:
		var index: int = 1
		for _i in range(items.size() - 2):
			var post_id: String = items[index].get("id", "")
			if post_id == data.get("id"): items.remove_at(index)
			index += 1
	if items.size() > 100: items.resize(100)
	forum_history["items"] = items
	Application.save_json_file(Application.FORUM_HISTORY_PATH, forum_history)
	Application.append_address.emit(data.get("title"), \
			"res://Scenes/Forum/PostMenu.tscn", \
			data)

func _on_member_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	member_total_label.text = "%s: %s" %[TranslationServer.translate("MEMBER_TOTAL_NAME"), json.get("total")]
	member_pagination_bar.total = ceili(float(json.get("total")) / LOADS_NUMBER)
	member_pagination_bar.update_pager_total()
	member_pagination_bar.visible = member_pagination_bar.total > 0
	var items: Array = json.get("items")
	for node in member_card_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		var member_card_scene = MEMBER_CARD_SCENE.instantiate()
		member_card_container.add_child(member_card_scene)
		member_card_scene.set_member_card_data(item)
		member_card_scene.pressed.connect(_on_member_card_pressed)

func _on_member_card_pressed(nick_name: String, user_id: int) -> void:
	Application.append_address.emit(nick_name, \
			"res://Scenes/User/UserMenu.tscn", \
			{"id": user_id})

func _on_selector_bar_index_pressed(index: int)-> void:
	if index == 0: works_request.request("https://api.codemao.cn/web/works/subjects/%s/works?&offset=0&limit=%s&sort=-created_at,-id&user_id=%s&work_subject_id=%s" %[id, LOADS_NUMBER, Application.user_id, id])
	elif index == 1: forum_request.request("https://api.codemao.cn/web/works/subjects/labels/%s/posts?limit=%s&offset=0" %[id, LOADS_NUMBER])
	elif index == 2: member_request.request("https://api.codemao.cn/web/shops/%s/users?limit=%s&offset=0" %[id, MEMBER_CARD_LOADS_NUMBER])
	submitted_works.visible = index == 0
	forum.visible = index == 1
	member.visible = index == 2

func _on_submitted_works_pagination_bar_page_changed(page: int) -> void:
	scroll_container.scroll_vertical = 218
	works_request.request("https://api.codemao.cn/web/works/subjects/%s/works?&offset=%s&limit=%s&sort=-created_at,-id&user_id=%s&work_subject_id=%s" %[id, (page - 1) * LOADS_NUMBER, LOADS_NUMBER, Application.user_id, id])

func _on_forum_pagination_bar_page_changed(page: int) -> void:
	scroll_container.scroll_vertical = 218
	forum_request.request("https://api.codemao.cn/web/works/subjects/labels/%s/posts?limit=%s&offset=%s" %[id, LOADS_NUMBER, (page - 1) * LOADS_NUMBER])

func _on_member_pagination_bar_page_changed(page: int) -> void:
	scroll_container.scroll_vertical = 218
	member_request.request("https://api.codemao.cn/web/shops/%s/users?limit=%s&offset=%s" %[id, MEMBER_CARD_LOADS_NUMBER, (page - 1) * MEMBER_CARD_LOADS_NUMBER])

func _on_comments_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	comments_total_label.text = "%s: %s" %[TranslationServer.translate("ALL_REPLIES_NAME"), (json.get("total") + json.get("totalReply"))]
	comments_pagination_bar.total = ceili(float(json.get("total")) / LOADS_NUMBER)
	comments_pagination_bar.update_pager_total()
	comments_pagination_bar.visible = comments_pagination_bar.total > 0
	var items: Array = json.get("items")
	for node in member_card_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		var replay_card_scene = REPLY_CARD_SCENE.instantiate()
		reply_card_container.add_child(replay_card_scene)
		replay_card_scene.set_reply_card_data(item)

func _on_comments_pagination_bar_page_changed(page: int) -> void:
	comments_request.request("https://api.codemao.cn/web/discussions/%s/comments?source=WORK_SHOP&sort=-created_at&limit=%s&offset=%s" %[id, COMMENTS_LOADS_NUMBER, (page - 1) * LOADS_NUMBER])

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0:
		name_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		description_label.add_theme_color_override("font_readonly_color", Color.html(GlobalTheme.light_mode_translucent_palette))
		total_score_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		member_total_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
		comments_total_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
	else:
		name_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		description_label.add_theme_color_override("font_readonly_color", Color.html(GlobalTheme.dark_mode_translucent_palette))
		total_score_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		member_total_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
		comments_total_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
