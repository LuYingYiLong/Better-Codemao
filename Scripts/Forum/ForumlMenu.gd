extends Control

@onready var boards_request = %BoardsRequest
@onready var search_request = %SearchRequest
@onready var all_request = %AllRequest
@onready var board_request = %BoardRequest
@onready var mine_posts_request = %MinePostsRequest
@onready var mine_replied_request = %MineRepliedRequest
@onready var scroll_container = %ScrollContainer

@onready var board_name_label = %BoardNameLabel
@onready var clear_history_button = %ClearHistoryButton
@onready var post_card_container = %PostCardContainer
@onready var pagination_bar = %PaginationBar

@onready var forum_board_card_container = %ForumBoardCardContainer

enum status_type{Forum, Board, MinePosts, MineReplied, History, Search}

const POST_CARD_SCENE = preload("res://Scenes/Forum/PostCard.tscn")
const BASE_BUTTON_SCENE = preload("res://Scenes/BaseUIComponents/BaseButton.tscn")

const LOADS_NUMBER: int = 30

var search: String
var boards_customized_res: Dictionary = {
	"17": {
		"name": TranslationServer.translate("POPULAR_ACTIVITIES_NAME")
	},
	"2": {
		"name": TranslationServer.translate("CODING_PARADISE_NAME")
	},
	"10": {
		"name": TranslationServer.translate("WORKSHOP_MASTER_APPRENTICE_NAME")
	},
	"5": {
		"name": TranslationServer.translate("YOU_ASK_I_ANSWER_NAME")
	},
	"3": {
		"name": TranslationServer.translate("THE_CODE_ISLAND_NAME")
	},
	"6": {
		"name": TranslationServer.translate("LIBRARY_NAME")
	},
	"27": {
		"name": TranslationServer.translate("COCO_APP_AUTHORING_NAME")
	},
	"11": {
		"name": TranslationServer.translate("PYTHON_PARADISE_NAME")
	},
	"26": {
		"name": TranslationServer.translate("THE_CODE_SPRITE_NAME")
	},
	"13": {
		"name": TranslationServer.translate("THE_NOC_MATCH_NAME")
	},
	"7": {
		"name": TranslationServer.translate("CHATTING_SQUARE_NAME")
	},
	"4": {
		"name": TranslationServer.translate("THE_TOWER_OF_BABEL_NAME")
	},
	"28": {
		"name": TranslationServer.translate("PROGRAMMER_CLASSROOM_NAME")
	}
}
var boards_data: Dictionary
var board_id: String
var status = status_type.Forum:
	set(value):
		status = value
		pagination_bar.current_page = 1
		pagination_bar.update_current_page()
		if status == status_type.Forum: load_forum()
		elif status == status_type.History: load_history()
		elif status == status_type.MinePosts: mine_posts_request.request("https://api.codemao.cn/web/forums/posts/mine/created?page=1&limit=%s" %LOADS_NUMBER, [Application.generate_cookie_header()])
		elif status == status_type.MineReplied: mine_replied_request.request("https://api.codemao.cn/web/forums/posts/mine/replied?page=1&limit=%s" %LOADS_NUMBER, [Application.generate_cookie_header()])
		elif status == status_type.Search: search_request.request("https://api.codemao.cn/web/forums/posts/search?title=%s&limit=%s&page=1" %[Application.string_to_hex(search), LOADS_NUMBER])
		clear_history_button.visible = status == status_type.History

func _ready() -> void:
	var headers = ["Content-Type: application/json"]
	boards_request.request("https://api.codemao.cn/web/forums/boards/simples/all", headers, HTTPClient.METHOD_GET)
	load_forum()
	Settings.settings_config_update.connect(_on_settings_config_update)
	_on_settings_config_update()

func load_forum() -> void:
	all_request.request("https://api.codemao.cn/web/forums/posts/hots/all")

func load_history() -> void:
	scroll_container.scroll_vertical = 0
	var forum_history: Dictionary = Application.load_json_file(Application.FORUM_HISTORY_PATH)
	var items: Array = forum_history.get("items", [])
	pagination_bar.total = ceili(float(items.size()) / LOADS_NUMBER)
	pagination_bar.update_pager_total()
	pagination_bar.visible = pagination_bar.total > 0
	for _i in range((pagination_bar.current_page - 1) * LOADS_NUMBER):
		items.remove_at(0)
	for node in post_card_container.get_children():
		node.queue_free()
	var count: int = -1
	for item: Dictionary in items:
		if count >= LOADS_NUMBER: break
		count += 1
		var post_card_scene = POST_CARD_SCENE.instantiate()
		post_card_container.add_child(post_card_scene)
		post_card_scene.set_post_card_data(item)
		post_card_scene.pressed.connect(on_post_card_scene_pressed)

func _on_auto_suggest_box_search_pressed(text: String) -> void:
	search = text
	status = status_type.Search

func on_boards_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	var items: Array = json.get("items")
	items.insert(0, {"id": "0", "name": TranslationServer.translate("FORUM_SQUARE_NAME")})
	boards_data = json
	for node in forum_board_card_container.get_children():
		node.queue_free()
	for item: Dictionary in items:
		var base_button_scene = BASE_BUTTON_SCENE.instantiate()
		forum_board_card_container.add_child(base_button_scene)
		base_button_scene.add_to_group("Boards")
		if boards_customized_res.has(item.get("id")):
			var key: String = item.get("id")
			if boards_customized_res.get(key).has("icon"): base_button_scene.icon = load(boards_customized_res.get(key).get("icon"))
			base_button_scene.text = boards_customized_res.get(key).get("name")
		else:
			base_button_scene.text = item.get("name")
		base_button_scene.group = "Boards"
		base_button_scene.metadata = {"id": item.get("id"), "name": base_button_scene.text}
		base_button_scene.metadata_output.connect(_on_board_button_metadata_output)

func _on_board_button_metadata_output(metadata: Dictionary) -> void:
	board_id = metadata.get("id")
	board_name_label.text = metadata.get("name")
	scroll_container.scroll_vertical = 0
	pagination_bar.current_page = 1
	pagination_bar.update_current_page()
	if board_id == "0":
		status = status_type.Forum
		_on_pagination_bar_page_changed(1)
	else:
		status = status_type.Board
		board_request.request("https://api.codemao.cn/web/forums/boards/%s/posts?page=1&limit=%s" %[board_id, LOADS_NUMBER])

func _on_search_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_class: JSON = JSON.new()
	if json_class.parse(body.get_string_from_utf8()) != OK:
		Application.emit_system_error_message("JSON parsing failed")
		return
	var json: Dictionary = json_class.data
	if result != HTTPRequest.RESULT_SUCCESS: return
	if json.has("error_code"):
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	for node in post_card_container.get_children():
		node.queue_free()
	pagination_bar.total = ceil(float(json.get("total")) / LOADS_NUMBER)
	pagination_bar.update_pager_total()
	pagination_bar.visible = pagination_bar.total > 0
	var items: Array = json.get("items")
	for item: Dictionary in items:
		var post_card_scene = POST_CARD_SCENE.instantiate()
		post_card_container.add_child(post_card_scene)
		post_card_scene.set_post_card_data(item)
		post_card_scene.pressed.connect(on_post_card_scene_pressed)

func on_all_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	for node in post_card_container.get_children():
		node.queue_free()
	var items: Array = json.get("items")
	pagination_bar.total = ceili(float(items.size()) / LOADS_NUMBER)
	pagination_bar.update_pager_total()
	pagination_bar.visible = pagination_bar.total > 0
	for _i in range((pagination_bar.current_page - 1) * LOADS_NUMBER):
		items.remove_at(0)
	var count: int = -1
	for post_id: String in items:
		if count >= LOADS_NUMBER: break
		count += 1
		var post_card_scene = POST_CARD_SCENE.instantiate()
		post_card_container.add_child(post_card_scene)
		post_card_scene.set_post_card_id(post_id)
		post_card_scene.pressed.connect(on_post_card_scene_pressed)

func _on_pagination_bar_page_changed(page: int) -> void:
	scroll_container.scroll_vertical = 0
	if status == status_type.Forum:
		all_request.request("https://api.codemao.cn/web/forums/posts/hots/all")
	elif status == status_type.Board:
		board_request.request("https://api.codemao.cn/web/forums/boards/%s/posts?page=%s&limit=%s" %[board_id, page, LOADS_NUMBER])
	elif status == status_type.MinePosts:
		mine_posts_request.request("https://api.codemao.cn/web/forums/posts/mine/created?page=%s&limit=%s" %[page, LOADS_NUMBER], [Application.generate_cookie_header()])
	elif status == status_type.MineReplied:
		mine_replied_request.request("https://api.codemao.cn/web/forums/posts/mine/replied?page=%s&limit=%s" %[page, LOADS_NUMBER], [Application.generate_cookie_header()])
	elif status == status_type.History:
		load_history()
	elif status == status_type.Search:
		search_request.request("https://api.codemao.cn/web/forums/posts/search?title=%s&limit=%s&page=%s" %[Application.string_to_hex(search), LOADS_NUMBER, page])

func _on_board_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	for node in post_card_container.get_children():
		node.queue_free()
	pagination_bar.total = ceili(float(json.get("total")) / LOADS_NUMBER)
	pagination_bar.update_pager_total()
	pagination_bar.visible = pagination_bar.total > 0
	var items: Array = json.get("items")
	for item: Dictionary in items:
		var post_card_scene = POST_CARD_SCENE.instantiate()
		post_card_container.add_child(post_card_scene)
		post_card_scene.set_post_card_data(item)
		post_card_scene.pressed.connect(on_post_card_scene_pressed)

func _on_mine_posts_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	if status == status_type.MinePosts:
		for node in post_card_container.get_children():
			node.queue_free()
		pagination_bar.total = ceili(float(json.get("total")) / LOADS_NUMBER)
		pagination_bar.update_pager_total()
		pagination_bar.visible = pagination_bar.total > 0
		var items: Array = json.get("items")
		for item: Dictionary in items:
			var post_card_scene = POST_CARD_SCENE.instantiate()
			post_card_container.add_child(post_card_scene)
			post_card_scene.set_post_card_data(item)
			post_card_scene.pressed.connect(on_post_card_scene_pressed)

func _on_mine_replied_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return

	if status == status_type.MineReplied:
		for node in post_card_container.get_children():
			node.queue_free()
		pagination_bar.total = ceili(float(json.get("total")) / LOADS_NUMBER)
		pagination_bar.update_pager_total()
		pagination_bar.visible = pagination_bar.total > 0
		var items: Array = json.get("items")
		for item: Dictionary in items:
			var post_card_scene = POST_CARD_SCENE.instantiate()
			post_card_container.add_child(post_card_scene)
			post_card_scene.set_post_card_data(item)
			post_card_scene.pressed.connect(on_post_card_scene_pressed)

func on_posts_received(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS:
		Application.emit_system_error_message("Error code: %s, Error message: %s" %[json.get("error_code", ""), json.get("error_message", "")])
		return
	if json.has("error_code"): return
	var post_card_scene = POST_CARD_SCENE.instantiate()
	post_card_container.add_child(post_card_scene)
	post_card_scene.set_post_card_data(json)
	post_card_scene.pressed.connect(on_post_card_scene_pressed)

func on_post_card_scene_pressed(data: Dictionary) -> void:
	var forum_history: Dictionary = Application.load_json_file(Application.FORUM_HISTORY_PATH)
	var items: Array = forum_history.get("items", [])
	items.insert(0, data)
	#检查items是否有和该帖子ID相匹配的item，若有则删除
	if items.size() >= 2:
		var index: int = 1
		for _i in range(items.size() - 2):
			var id: String = items[index].get("id", "")
			if id == data.get("id"): items.remove_at(index)
			index += 1
	if items.size() > 100: items.resize(100)
	forum_history["items"] = items
	Application.save_json_file(Application.FORUM_HISTORY_PATH, forum_history)
	Application.append_address.emit(data.get("title"), \
			"res://Scenes/Forum/PostMenu.tscn", \
			data)

func _on_mine_posts_button_pressed():
	status = status_type.MinePosts
	board_name_label.text = TranslationServer.translate("MINE_POSTS_NAME")

func _on_mine_replied_button_pressed():
	status = status_type.MineReplied
	board_name_label.text = TranslationServer.translate("MINE_REPLIED_NAME")

func _on_history_button_pressed():
	status = status_type.History
	board_name_label.text = TranslationServer.translate("HISTORY_NAME")

func _on_clear_history_button_pressed():
	var content_dialog = Application.get_content_dialog()
	if !content_dialog.is_connected("callback", _content_dialog_callback): content_dialog.callback.connect(_content_dialog_callback)
	content_dialog.title = "%s?" %TranslationServer.translate("HISTORY_NAME")
	content_dialog.text = TranslationServer.translate("CLEAR_HISTORY_DESCRIPTION")
	content_dialog.popup_item.clear()
	var get_updates_item: PopupItem = PopupItem.new()
	get_updates_item.text = "CONTINUE_NAME"
	get_updates_item.flat = true
	content_dialog.popup_item.append(get_updates_item)
	var cancel_item: PopupItem = PopupItem.new()
	cancel_item.text = "CANCEL_NAME"
	content_dialog.popup_item.append(cancel_item)
	content_dialog.show_content_dialog()

func _content_dialog_callback(index: int) -> void:
	if index == 0:
		var forum_history: Dictionary = Application.load_json_file(Application.FORUM_HISTORY_PATH)
		forum_history["items"] = []
		Application.save_json_file(Application.FORUM_HISTORY_PATH, forum_history)
		if status == status_type.History:
			for node in post_card_container.get_children():
				node.queue_free()
			pagination_bar.hide()
	var content_dialog = Application.get_content_dialog()
	content_dialog.hide_content_dialog()
	content_dialog.disconnect("callback", _content_dialog_callback)

func _on_settings_config_update() -> void:
	if Settings.dark_mode == 0: board_name_label.add_theme_color_override("font_color", Color.html(GlobalTheme.light_mode_font_color))
	else: board_name_label.add_theme_color_override("font_color", Color.html(GlobalTheme.dark_mode_font_color))
